//
//  GalleryVC.swift
//  Phoneado
//
//  Created by Zimble on 3/28/22.
//

import UIKit
import Photos
import SDWebImage

class GalleryVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var syncBackView: UIView!
    @IBOutlet weak var photosCV: UICollectionView!
    @IBOutlet weak var photosLbl: UILabel!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var albumView: UIView!
    @IBOutlet weak var albumLbl: UILabel!
    //MARK: - Variable
    var selection = 1
    var allPhotos : PHFetchResult<PHAsset>?
    var assets = [PHAsset]()
    var images = [UIImage]()
    var thumbs = [UIImage]()
    
    var albumTitlesAndCount = [[String:Any]]()
    var albumAndPhotosInAlbum = [String:UIImage]()
    var albumImagesArray = [UIImage]()
    var key = [String]()
    var value = [Int]()
    var imagesList : [ImageList] = []
    var cameraImagesList : [ImageList] = []
    var getGalleryImagesData:GetGalleryImagesData?
    var getUploadedImagesId:GetGalleryImagesData?
    var selectedIndexRow = [Int]()
    var imagesUniqueID = [String]()
    var imagesName = [String]()
    var imagesData = [Data]()
    var request = [String]()
    var userLoginType = ""
    var imagesHashValues = [String]()
    var uploadedImagesHashValues = [String]()
    var imagestoUpload: [String:Any] = [:]
    var suncedImagesforAlbum: [String] = []
    var longPressed: Bool = false
    let myQueue = OperationQueue()
    var imagesAdded: Bool = false
    let page = 10
    var beginIndex = 0
    var endIndex = 9
    var loading = false
    var hasNextPage = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(signinNotificationHandler(notificationInfo:)),
                                               name: Notification.Name.SigninNotification,
                                               object: nil)
        
        if (userLoginType == "") {
            let type = Storage.shared.isAdminUser()
            self.userLoginType = type!
        }
        if userLoginType == "Admin" {
            self.syncBackView.isHidden = false
            self.albumView.isHidden = false
            self.images.removeAll()
            self.imagesAdded = false
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == PHAuthorizationStatus.authorized) {
                let options = PHFetchOptions()
                options.includeHiddenAssets = true
                allPhotos = PHAsset.fetchAssets(with: .image, options: options)
                getImages(isFirstTime: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.getImagesUniqueIDRequest()
                }
            } else if (status == PHAuthorizationStatus.denied) {
                self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
            } else if (status == PHAuthorizationStatus.notDetermined) {
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if (newStatus == PHAuthorizationStatus.authorized) {
                        let options = PHFetchOptions()
                        options.includeHiddenAssets = true
                        self.allPhotos = PHAsset.fetchAssets(with: .image, options: options)
                        self.getImages(isFirstTime: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.getImagesUniqueIDRequest()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
                        }
                    }
                })
            }
        } else {
            self.syncBackView.isHidden = true
            self.albumView.isHidden = true
            getGalleryImagesRequest()
        }
    }
    
    func getImages(isFirstTime:Bool) {
        endIndex = beginIndex + (page - 1)
        if endIndex >= allPhotos!.count {
            endIndex = allPhotos!.count - 1
        }
        
        if (beginIndex >= 0 && endIndex >= 0) {
            let arr = Array(beginIndex...endIndex)
            let indexSet = IndexSet(arr)
            fetchPhotos(indexSet: indexSet,isFirstTime: isFirstTime)
        }
    }
    
    fileprivate func fetchPhotos(indexSet: IndexSet,isFirstTime:Bool) {
        
        if allPhotos!.count == self.thumbs.count {
            self.hasNextPage = false
            self.loading = false
            Constant.appDelegate.hideProgressHUD()
            return
        }
        self.loading = true
        if (isFirstTime) {
            Constant.appDelegate.showProgressHUD(view: self.view)
            
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.allPhotos?.enumerateObjects(at: indexSet, options: NSEnumerationOptions.concurrent, using: { (asset, count, stop) in
                guard let weakSelf = self else {
                    return
                }
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 250, height: 450), contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        weakSelf.thumbs.append(image)
                        weakSelf.assets.append(asset)
                        weakSelf.imagesHashValues.append(image.sha256())
                    } else {
                        weakSelf.thumbs.append(UIImage(named: "country")!)
                        weakSelf.imagesHashValues.append(UIImage(named: "country")!.sha256())
                    }
                })
                if weakSelf.thumbs.count - 1 == indexSet.last! {
                    print("last element")
                    weakSelf.loading = false
                    weakSelf.hasNextPage = weakSelf.thumbs.count != weakSelf.allPhotos!.count
                    weakSelf.beginIndex = weakSelf.thumbs.count
                    DispatchQueue.main.async {
                        weakSelf.photosCV.reloadData()
                        Constant.appDelegate.hideProgressHUD()
                    }
                }
                
            })
        }
    }
    
    @IBAction func sideMenuTapped(_ sender: Any) {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
        vc.userLoginType = self.userLoginType
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func signinNotificationHandler(notificationInfo:Notification) {
        if let userInfo = notificationInfo.userInfo as? [String:Any] {
            if let userLoginType = userInfo["UserLoginType"] as? String {
                print("user Logi type is :", userLoginType)
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.photosCV.isScrollEnabled = true
        getGalleryImagesRequest()
        collectionViewSetup()
        self.imagestoUpload.removeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.photosCV.isScrollEnabled = false
    }
    
    func collectionViewSetup() {
        photosCV.delegate = self
        photosCV.dataSource = self
        photosCV.register(UINib(nibName: "GalleryPhotosCVC", bundle: nil), forCellWithReuseIdentifier: "GalleryPhotosCVC")
        photosCV.register(UINib(nibName: "GalleryAlbumCVC", bundle: nil), forCellWithReuseIdentifier: "GalleryAlbumCVC")
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .began {
            return
        }
        let p = gesture.location(in: self.photosCV)
        if let indexPath = self.photosCV.indexPathForItem(at: p) {
            let cell = self.photosCV.cellForItem(at: indexPath) as! GalleryPhotosCVC
            print("Selected Index Path = \(indexPath)")
            if indexPath.item < self.cameraImagesList.count
            {
                Alert().showAlert(message: "This image is already synced.")
            } else {
                if self.cameraImagesList.count > 0 {
                    let adjustedIndex = indexPath.item - self.cameraImagesList.count
                    print(adjustedIndex)
                    let id_str = self.thumbs[adjustedIndex].sha256()
                    print("IDSTR == \(id_str)")
                    if self.uploadedImagesHashValues.contains(id_str) {
                        cell.selectImgView.isHidden = false
                        Alert().showAlert(message: "This image is already synced.")
                    } else {
                        cell.selectImgView.isHidden = false
                        if !selectedIndexRow.contains(adjustedIndex) {
                            self.selectedIndexRow.append(adjustedIndex)
                        }
                    }
                    print("hiii Selected Index Path Row with Long Press Gesture = \(self.selectedIndexRow)")
                } else {
                    let id_str = self.thumbs[indexPath.row].sha256()
                    print("IDSTR == \(id_str)")
                    if self.uploadedImagesHashValues.contains(id_str) {
                        cell.selectImgView.isHidden = false
                        Alert().showAlert(message: "This image is already synced.")
                    } else {
                        cell.selectImgView.isHidden = false
                        if !selectedIndexRow.contains(indexPath.row) {
                            self.selectedIndexRow.append(indexPath.row)
                        }
                    }
                    print("hiii Selected Index Path Row with Long Press Gesture = \(self.selectedIndexRow)")
                }
            }
        } else {
            print("couldn't find index path")
        }
    }
    
    func alertToEncouragePhotoLibraryAccessWhenApplicationStarts() {
        //Photo Library not available - Alert
        let cameraUnavailableAlertController = UIAlertController (title: "Photo Library Unavailable", message: "Please check to see if device settings doesn't allow photo library access", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(settingsAction)
        cameraUnavailableAlertController .addAction(cancelAction)
        self.present(cameraUnavailableAlertController, animated: true, completion: nil)
        
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    
    func fetchImagesAlbum(isFirstTime:Bool) {
        
        Constant.appDelegate.showProgressHUD(view: self.view)
        
        self.albumTitlesAndCount.removeAll()
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            let fetchOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            let topLevelfetchOptions = PHFetchOptions()
            let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: topLevelfetchOptions)
            _ = [topLevelUserCollections, smartAlbums]
            let customAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            let allAlbums0 = [customAlbums,smartAlbums]
            
            var count = 0
            
            allAlbums0.forEach {
                $0.enumerateObjects { collection, index, stop in
                    let imgManager = PHImageManager.default()
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    requestOptions.deliveryMode = .highQualityFormat
                    let photoInAlbum = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    count = count + 1
                    if let title = collection.localizedTitle {
                        if photoInAlbum.count > 0 {
                            print("\n\n \(title) --- count = \(photoInAlbum.count) \n\n")
                            if title != "Videos" {
                                DispatchQueue.main.async {
                                    
                                    if photoInAlbum.count > 0 {
                                        
                                        imgManager.requestImage(for: photoInAlbum.object(at: 0) as PHAsset , targetSize: CGSize(width: 250, height: 450), contentMode: .aspectFit, options: requestOptions, resultHandler: {
                                            image, error in
                                            if image != nil {
                                                let obj = ["title":title,"count":"\(photoInAlbum.count)","image":image!] as [String : Any]
                                                
                                                weakSelf.albumTitlesAndCount.append(obj)
                                                weakSelf.photosCV.reloadData()
                                                Constant.appDelegate.hideProgressHUD()
                                            } else {
                                                let obj = ["title":title,"count":"\(photoInAlbum.count)"] as [String : Any]
                                                
                                                weakSelf.albumTitlesAndCount.append(obj)
                                                weakSelf.photosCV.reloadData()
                                                Constant.appDelegate.hideProgressHUD()
                                            }
                                        })
                                    } else {
                                        let obj = ["title":title,"count":"\(photoInAlbum.count)"] as [String : Any]
                                        weakSelf.albumTitlesAndCount.append(obj)
                                        weakSelf.photosCV.reloadData()
                                        Constant.appDelegate.hideProgressHUD()
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    //MARK: - IB Actions
    @IBAction func photosTapped(_ sender: Any) {
        selection = 1
        photosLbl.textColor = UIColor(named: "AppColor")
        albumLbl.textColor = UIColor(named: "DarkGrayTextColor")
        
        photosCV.reloadData()
    }
    @IBAction func albumsTapped(_ sender: Any) {
        selection = 2
        albumLbl.textColor = UIColor(named: "AppColor")
        photosLbl.textColor = UIColor(named: "DarkGrayTextColor")
        self.fetchImagesAlbum(isFirstTime: true)
    }
    @IBAction func syncTapped(_ sender: Any) {
        if selectedIndexRow.count > 0 {
            let vc = ConsentViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
            vc.delegate = self
            vc.fromGallaryVC = true
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        } else {
            Alert().showAlert(message: "Select atleast one image to sync.")
        }
    }
    
    func startSync() {
        if userLoginType == "Admin" {
            //            if self.selectedIndexRow.isEmpty {
            //                Alert().showAlert(message: "Select Image to sync.")
            //            }
            //            else {
            self.imagestoUpload.removeAll()
            self.imagesData.removeAll()
            self.request.removeAll()
            var id_str = ""
            
            for i in self.selectedIndexRow{
                if let imageData = self.thumbs[i].pngData() {
                    print("Image Data = \(imageData)")
                    self.imagesData.append(imageData)
                    id_str = self.thumbs[i].sha256()
                    print("ID = \(id_str)")
                    self.request.append(id_str)
                    
                    self.imagestoUpload.updateValue(imageData, forKey: id_str)
                }
            }
            DispatchQueue.main.async {
                self.uploadGalleryImagesRequest(imageIndex: 0, imagetoUpload: self.imagestoUpload)
            }
            //            }
        } else {
            Alert().showAlert(message: "Cannot sync image.Login as Admin.")
        }
    }
}
extension GalleryVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selection == 1 {
            let width = collectionView.bounds.width / 4
            let height = 130//collectionView.bounds.height / 2 - 90
            return CGSize(width: width, height: CGFloat(height))
        } else {
            let width = collectionView.bounds.width
            let height = CGFloat(100)
            return CGSize(width: width, height: height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if selection == 1 {
            if userLoginType == "Admin" {
                return 1
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selection == 1 {
            if userLoginType == "Admin" {
                let count = self.cameraImagesList.count + self.thumbs.count
                return count
            } else {
                return self.imagesList.count
            }
        } else {
            return self.albumTitlesAndCount.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selection == 1 {
            let cell = photosCV.dequeueReusableCell(withReuseIdentifier: "GalleryPhotosCVC", for: indexPath) as! GalleryPhotosCVC
            if userLoginType == "Admin" {
                if indexPath.item < self.cameraImagesList.count {
                    if self.cameraImagesList.count > 0 {
                        if self.cameraImagesList[indexPath.row].cameraUpload {
                            cell.imgView.sd_setImage(with: URL(string: self.cameraImagesList[indexPath.row].url), placeholderImage: UIImage(named: "Gallery-1"))
                            cell.selectImgView.isHidden = false
                            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                            cell.addGestureRecognizer(lpgr)
                        }
                    }
                } else {
                    if self.thumbs.count > 0 {
                        if self.cameraImagesList.count > 0 {
                            let adjustedIndex = indexPath.item - self.cameraImagesList.count
                            print(adjustedIndex)
                            let id_str = self.thumbs[adjustedIndex].sha256()
                            if imagesList.contains(where: {$0.id == id_str}){
                                self.uploadedImagesHashValues.append(id_str)
                                cell.selectImgView.isHidden = false
                            } else {
                                cell.selectImgView.isHidden = true
                            }
                            cell.imgView.image = self.thumbs[adjustedIndex]
                            if self.hasNextPage && !loading && indexPath.row == self.thumbs.count - 1 {
                                getImages(isFirstTime: false)
                            }
                            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                            cell.addGestureRecognizer(lpgr)
                        } else {
                            let id_str = self.thumbs[indexPath.item].sha256()
                            if imagesList.contains(where: {$0.id == id_str}){
                                self.uploadedImagesHashValues.append(id_str)
                                cell.selectImgView.isHidden = false
                            } else {
                                cell.selectImgView.isHidden = true
                            }
                            cell.imgView.image = self.thumbs[indexPath.item]
                            if self.hasNextPage && !loading && indexPath.row == self.thumbs.count - 1 {
                                getImages(isFirstTime: false)
                            }
                            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                            cell.addGestureRecognizer(lpgr)
                        }
                    }
                }
            } else {
                cell.imgView.sd_setImage(with: URL(string: self.imagesList[indexPath.row].url), placeholderImage: UIImage(named: "Gallery-1"))
                let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                cell.addGestureRecognizer(lpgr)
            }
            return cell
        } else {
            let cell = photosCV.dequeueReusableCell(withReuseIdentifier: "GalleryAlbumCVC", for: indexPath) as! GalleryAlbumCVC
            
            if (indexPath.item < albumTitlesAndCount.count){
                let obj = albumTitlesAndCount[indexPath.item]
                cell.albumTitleLbl.text = (obj["title"] as! String)
                cell.albumImageCountLbl.text = (obj["count"] as! String)
                
                if (obj["image"] != nil){
                    if let imageData = (obj["image"] as! UIImage).pngData() {
                        let options = [
                            kCGImageSourceCreateThumbnailWithTransform: true,
                            kCGImageSourceCreateThumbnailFromImageAlways: true,
                            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
                        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
                        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
                        let thumbnail = UIImage(cgImage: imageReference)
                        cell.albumThumbnailImgView.image = thumbnail
                    }
                }
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selection != 1{
            let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "albumPhotosVC") as! albumPhotosVC
            let obj = self.albumTitlesAndCount[indexPath.item]
            vc.albumTitle = (obj["title"] as! String)
            vc.albumCount = Int((obj["count"] as! String))!
            vc.userLoginType = self.userLoginType
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if self.cameraImagesList.count > 0 {
                let adjustedIndex = indexPath.item - self.cameraImagesList.count
                print(adjustedIndex)
                if self.selectedIndexRow.contains(adjustedIndex) {
                    let cell = self.photosCV.cellForItem(at: indexPath) as! GalleryPhotosCVC
                    let id_str = self.thumbs[adjustedIndex].sha256()
                    if self.uploadedImagesHashValues.contains(id_str) {
                        cell.selectImgView.isHidden = false
                        Alert().showAlert(message: "This image is already synced.")
                        self.selectedIndexRow.remove(element: adjustedIndex)
                    } else {
                        cell.selectImgView.isHidden = true
                        self.selectedIndexRow.remove(element: adjustedIndex)
                    }
                    print("Selected Index Path Row with Long Press Gesture = \(self.selectedIndexRow)")
                } else {
                    if indexPath.item < self.cameraImagesList.count {
                        if self.cameraImagesList.count > 0 {
                            let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                            vc.url = self.cameraImagesList[indexPath.item].url
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        if self.thumbs.count > 0 {
                            let imgManager = PHImageManager.default()
                            let requestOptions = PHImageRequestOptions()
                            requestOptions.isSynchronous = true
                            requestOptions.deliveryMode = .highQualityFormat
                            if self.cameraImagesList.count > 0 {
                                let adjustedIndex = indexPath.item - self.cameraImagesList.count
                                print(adjustedIndex)
                                imgManager.requestImage(for: self.allPhotos!.object(at: adjustedIndex) as PHAsset , targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: {
                                    image, error in
                                    if image != nil {
                                        let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                                        vc.image = image!
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                })
                            } else {
                                imgManager.requestImage(for: self.allPhotos!.object(at: indexPath.item) as PHAsset , targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: {
                                    image, error in
                                    if image != nil {
                                        let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                                        vc.image = image!
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                })
                            }
                        } else {
                            let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                            vc.url = self.imagesList[indexPath.row].url
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            } else {
                if self.selectedIndexRow.contains(indexPath.row) {
                    let cell = self.photosCV.cellForItem(at: indexPath) as! GalleryPhotosCVC
                    let id_str = self.thumbs[indexPath.row].sha256()
                    if self.uploadedImagesHashValues.contains(id_str) {
                        cell.selectImgView.isHidden = false
                        Alert().showAlert(message: "This image is already synced.")
                        self.selectedIndexRow.remove(element: indexPath.row)
                    } else {
                        cell.selectImgView.isHidden = true
                        self.selectedIndexRow.remove(element: indexPath.row)
                    }
                    print("Selected Index Path Row with Long Press Gesture = \(self.selectedIndexRow)")
                } else {
                    if self.thumbs.count > 0 {
                        let imgManager = PHImageManager.default()
                        let requestOptions = PHImageRequestOptions()
                        requestOptions.isSynchronous = true
                        requestOptions.deliveryMode = .highQualityFormat
                        
                        imgManager.requestImage(for: self.allPhotos!.object(at: indexPath.item) as PHAsset , targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: {
                            image, error in
                            if image != nil {
                                let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                                vc.image = image!
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        })
                    } else {
                        let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                        vc.url = self.imagesList[indexPath.row].url
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}
extension GalleryVC {
    func uploadGalleryImagesRequest(imageIndex: Int, vidData: [Data]? = nil, imagetoUpload: [String:Any]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        for (i,j) in imagetoUpload{
            LoggedInRequest().uploadGalleryImagesRequest(imageIndex: imageIndex, imagesData: j as! Data, params: ["id":i], vidData: vidData, callback: { (response, error) in
                Constant.appDelegate.hideProgressHUD()
                if error == nil {
                    self.selectedIndexRow.removeAll()
                    print("Upload Images Response = \(response ?? [:])")
                    let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                    guard let data = jsonData else { return }
                    do {
                        let responseData = try JSONDecoder().decode(UploadGalleryImageModel.self, from: data)
                        print("Response Data = \(responseData)")
                        self.show(message: responseData.message,controller: self)
                        self.imagesData.removeAll()
                    } catch let err {
                        print("Err", err)
                    }
                } else {
                    self.selectedIndexRow.removeAll()
                    Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                }
            })
        }
    }
    func getGalleryImagesRequest(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getGalleryImagesRequest(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                print("Get Gallery Images Response = \(response ?? [:])")
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                
                let responseData = try? JSONDecoder().decode(GetGalleryImagesModel.self, from: data)
                self.getGalleryImagesData = responseData?.data
                var imageArray: [ImageList] = []
                if let array: NSArray = response?["imageList"] as! NSArray? {
                    for post in array {
                        if let dict: [String:Any] = post as! [String:Any]? {
                            let images = ImageList.init(fromDictionary: dict )
                            imageArray.append(images)
                        }
                    }
                }
                self.imagesList = imageArray
                self.photosCV.reloadData()
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                print("Error = \(error?.message ?? TextString.inValidResponseError)")
            }
        }
    }
    func getImagesUniqueIDRequest(requestParams: [String: Any] = [:]) { //,callback: @escaping (String) -> ()
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getImagesUniqueIDRequest(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                print("Get Gallery Images Response = \(response ?? [:])")
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                
                let responseData = try? JSONDecoder().decode(GetGalleryImagesModel.self, from: data)
                self.getUploadedImagesId = responseData?.data
                var imageArray: [ImageList] = []
                if let array: NSArray = response?["imageList"] as! NSArray? {
                    for post in array {
                        if let dict: [String:Any] = post as! [String:Any]? {
                            let images = ImageList.init(fromDictionary: dict )
                            imageArray.append(images)
                        }
                    }
                }
                
                if imageArray.count > 0 {
                    for i in imageArray {
                        if i.cameraUpload {
                            self.cameraImagesList.append(i)
                        }
                    }
                }
                self.photosCV.reloadData()
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                print("Error = \(error?.message ?? TextString.inValidResponseError)")
            }
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
extension GalleryVC: ConsentDelegate {
    
    func selectedOption(sender: ConsentViewController, agree: Bool) {
        if agree {
            self.startSync()
        }
    }
}
