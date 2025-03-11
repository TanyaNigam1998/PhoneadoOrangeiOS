//
//  albumPhotosVC.swift
//  Phoneado
//
//  Created by Zimble on 4/6/22.
//

import UIKit
import Photos
class albumPhotosVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var albumPhotosCV: UICollectionView!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var albumTitleLbl: UILabel!
    //MARK: - Variables
    var albumTitle = String()
    var albumCount = Int()
    var albumImages = [UIImage]()
    var syncedImages = [String]()
    var imagesList : [ImageList] = []
    var images = [UIImage]()
    var thumb = [UIImage]()
    var imagesData = [Data]()
    var request = [String]()
    var uploadedImagesHashValues = [String]()
    var selectedIndexRow = [Int]()
    var getUploadedImagesId:GetGalleryImagesData?
    var imagestoUpload: [String:Any] = [:]
    var imagesofParticularAlbum = [UIImage]()
    var assets = [PHAsset]()
    var imagesHashValues = [String]()
    var userLoginType = ""
    
    
    let page = 20
    var beginIndex = 0
    var endIndex = 9
    var loading = false
    var hasNextPage = false
    
    var myCount:Int = Int()
    var totalCount:Int = Int()
    var isLoading:Bool = Bool()

    var allAssets : PHFetchResult<PHAsset>?

    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        myCount = 0
        isLoading = true
        getImagesUniqueIDRequest()
        self.fetchCustomAlbumPhotos(isFirstTime: true)
        // Do any additional setup after loading the view.
    }
    func initialViewSetup() {
        albumTitleLbl.text = "\(albumTitle)(\(albumCount))"
        collectionViewSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imagestoUpload.removeAll()
    }
    func collectionViewSetup() {
        albumPhotosCV.delegate = self
        albumPhotosCV.dataSource = self
        albumPhotosCV.register(UINib(nibName: "GalleryPhotosCVC", bundle: nil), forCellWithReuseIdentifier: "GalleryPhotosCVC")
        albumPhotosCV.register(UINib(nibName: "GalleryAlbumCVC", bundle: nil), forCellWithReuseIdentifier: "GalleryAlbumCVC")
        albumPhotosCV.reloadData()
    }
    //MARK: - IB Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func startSync()
    {
        if userLoginType == "Admin" {
            if self.selectedIndexRow.isEmpty {
                Alert().showAlert(message: "Select Image to sync.")
            }
            else {
                self.imagestoUpload.removeAll()
                self.imagesData.removeAll()
                self.request.removeAll()
                var requestDict = [String: Any]()
                var id_str = ""
                
                var count:Int = Int()
                
                for i in self.selectedIndexRow{
                    
                    
                    let imgManager = PHImageManager.default()
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    requestOptions.deliveryMode = .highQualityFormat
                    
                    imgManager.requestImage(for: self.allAssets!.object(at:i) as PHAsset , targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: {
                        image, error in
                        if image != nil
                        {
                            
                            if let imageData = image!.pngData() {
                                print("Image Data = \(imageData)")
                                self.imagesData.append(imageData)
                                let id_str = self.thumb[i].sha256()
                                print("ID = \(id_str)")
                                self.request.append(id_str)
                                self.imagestoUpload.updateValue(imageData, forKey: id_str)
                            }
                            

                  
                        }else{
                            
                            //Courrpted Image
                        }
                        
                        count =  count + 1
                        
                        if (count == self.selectedIndexRow.count){
                            
                            DispatchQueue.main.async {
                                self.uploadGalleryImagesRequest(imageIndex: 0, imagetoUpload: self.imagestoUpload)
                            }

                        }
                    })

                    
                }
                
     
            }
        }else {
            Alert().showAlert(message: "Cannot sync image.Login as Admin.")
        }
    }
    
    
    @IBAction func syncButtonClicked(_ sender: Any) {
        
        let vc = ConsentViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
        vc.delegate = self
        vc.fromGallaryVC = true
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
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

    func getImages(isFirstTime:Bool){
        endIndex = beginIndex + (page - 1)
        if endIndex >= albumCount {
            endIndex = albumCount - 1
        }
        
        if (beginIndex >= 0 && endIndex >= 0){
            let arr = Array(beginIndex...endIndex)
            let indexSet = IndexSet(arr)
            //fetchCustomAlbumPhotos(indexSet: indexSet,isFirstTime: isFirstTime)
        }
    }
    
    
    func fetchFurtherData(){
        
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat

        if self.totalCount > 0 && self.myCount <  self.totalCount
        {
            
            var total:Int = Int()
            total = self.myCount + self.page

            if (self.myCount + self.page > self.totalCount - 1){
                var new = total - self.totalCount
                total = total - new
            }
                        
            for i in (self.myCount..<total)
            {
 
                
 
                imgManager.requestImage(for: self.allAssets!.object(at: i) as PHAsset , targetSize:CGSize(width: 250, height: 450), contentMode: .aspectFit, options: requestOptions, resultHandler: {
                    image, error in
                    if image != nil
                    {
                        self.imagesofParticularAlbum.append(image!)
                        self.thumb.append(image!)
                        self.assets.append(self.allAssets!.object(at: i))
                        self.imagesHashValues.append(image!.sha256())
                       // let thumb = self.getAssetThumbnail(asset:self.allAssets!.object(at: i))
                      //  self.thumb.append(thumb)
                    }else{
                        self.imagesofParticularAlbum.append(UIImage(named: "country")!)
                        self.thumb.append(UIImage(named: "country")!)
                        self.imagesHashValues.append(UIImage(named: "country")!.sha256())


                    }
                    
                    print("MyCount:-- \(self.myCount)")
                    self.myCount = self.myCount + 1
                    
                    if (self.myCount == total - 1){
                        self.isLoading = false
                        DispatchQueue.main.async {
                        self.albumPhotosCV.reloadData()
                        }

                    }
                    
                })
                
            }
        }
        
    }

    
    func fetchCustomAlbumPhotos(isFirstTime:Bool)
    {
        
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
                    let photoInAlbum = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    if let title = collection.localizedTitle {
                        if photoInAlbum.count > 0 {
                            if title != "Videos" {
                            
                                if (title == self?.albumTitle){
                                    
                                    self!.totalCount = photoInAlbum.count
                                    self?.allAssets = photoInAlbum
                                    self?.fetchFurtherData()
                                                                    
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getImagesUniqueIDRequest(requestParams:[String:Any] = [:]) { //,callback: @escaping (String) -> ()
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
                print("getUploadedImagesId = \(self.getUploadedImagesId)")
                
                var imageArray: [ImageList] = []
                if let array: NSArray = response?["imageList"] as! NSArray?
                {
                    for post in array
                    {
                        if let dict: [String:Any] = post as! [String:Any]?
                        {
                            let images = ImageList.init(fromDictionary: dict )
                            imageArray.append(images)
                        }
                    }
                }
                self.imagesList = imageArray
                self.albumPhotosCV.reloadData()
            }
            else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                print("Error = \(error?.message ?? TextString.inValidResponseError)")
            }
        }
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .began {
            return
        }
        let p = gesture.location(in: self.albumPhotosCV)
        if let indexPath = self.albumPhotosCV.indexPathForItem(at: p) {
            let cell = self.albumPhotosCV.cellForItem(at: indexPath) as! GalleryPhotosCVC
            print("Selected Index Path = \(indexPath)")
            let id_str = self.thumb[indexPath.row].sha256()
            if self.uploadedImagesHashValues.contains(id_str) {
                cell.selectImgView.isHidden = false
                Alert().showAlert(message: "This image is already synced.")
            }else {
                cell.selectImgView.isHidden = false
                if !selectedIndexRow.contains(indexPath.row) {
                    self.selectedIndexRow.append(indexPath.row)
                }
            }
            print(id_str)
            print("Selected Index Path Row with Long Press Gesture = \(self.selectedIndexRow)")
        }else {
            print("couldn't find index path")
        }
    }
}
extension albumPhotosVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 4
        let height = 130//collectionView.bounds.height / 2 - 90
        return CGSize(width: width, height: CGFloat(height))
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
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumb.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumPhotosCV.dequeueReusableCell(withReuseIdentifier: "GalleryPhotosCVC", for: indexPath) as! GalleryPhotosCVC
        
        if (indexPath.item < thumb.count){
            
            cell.imgView.image = thumb[indexPath.item]
            
            let id_str = self.thumb[indexPath.row].sha256()
            
            let uploadedImagesCount = self.getUploadedImagesId?.totalImages ?? 0
            print("Images Hash value = \(id_str)")

            if imagesList.contains(where: {$0.id == id_str}) || syncedImages.contains(where: {$0 == id_str}){
                self.uploadedImagesHashValues.append(id_str)
                cell.selectImgView.isHidden = false
            }else{
                cell.selectImgView.isHidden = true
            }

            cell.imgView.image = thumb[indexPath.item]
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            cell.addGestureRecognizer(lpgr)

        }
        
        
        
        //let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        //cell.addGestureRecognizer(lpgr)
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("connecrt")

        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
                
        if self.myCount < self.totalCount && !isLoading{
            print("Enter")
            isLoading = true
           fetchFurtherData()
        }

        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if self.selectedIndexRow.contains(indexPath.row)
        {
            let cell = self.albumPhotosCV.cellForItem(at: indexPath) as! GalleryPhotosCVC
            let id_str = self.thumb[indexPath.row].sha256()
            if self.uploadedImagesHashValues.contains(id_str) {
                cell.selectImgView.isHidden = false
                Alert().showAlert(message: "This image is already synced.")
                self.selectedIndexRow.remove(element: indexPath.row)
            }else {
                cell.selectImgView.isHidden = true
                self.selectedIndexRow.remove(element: indexPath.row)
            }
            print("Selected Index Path Row with Long Press Gesture = \(self.selectedIndexRow)")
        }else{
            if self.thumb.count > 0
            {
                
                let imgManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.deliveryMode = .highQualityFormat
                
                imgManager.requestImage(for: self.allAssets!.object(at: indexPath.item) as PHAsset , targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: {
                    image, error in
                    if image != nil
                    {
                        let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                        vc.image = image!
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }else
            {
                
                let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                vc.url = self.getUploadedImagesId?.imageList[indexPath.row].url ?? ""
                self.navigationController?.pushViewController(vc, animated: true)

                
//                let vc = GuestImageViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
//                vc.celeImg = self.getUploadedImagesId?.imageList[indexPath.row].url ?? ""
//                self.present(vc, animated: true)

            }
        }
        
        //        let cell = self.albumPhotosCV.cellForItem(at: indexPath) as! GalleryPhotosCVC
        //        let id_str = self.imagesofParticularAlbum[indexPath.row].sha256()
        //        if self.uploadedImagesHashValues.contains(id_str) {
        //            cell.selectImgView.isHidden = false
        //            Alert().showAlert(message: "This image is already synced.")
        //            self.selectedIndexRow.remove(element: indexPath.row)
        //        }else {
        //            cell.selectImgView.isHidden = true
        //            self.selectedIndexRow.remove(element: indexPath.row)
        //        }
        //        print("Selected Index Path Row with Long Press Gesture = \(self.selectedIndexRow)")
        
    }
    
}

extension albumPhotosVC {
    func uploadGalleryImagesRequest(imageIndex: Int, vidData: [Data]? = nil, imagetoUpload: [String:Any]) {
        self.view.endEditing(true)
        //        var count = 0
        Constant.appDelegate.showProgressHUD(view: self.view)
        //        requestDict = ["id":id_str]
        
        for (i,j) in imagetoUpload{
            //        repeat{
            //            count = count + 1
            LoggedInRequest().uploadGalleryImagesRequest(imageIndex: imageIndex, imagesData: j as! Data, params: ["id":i], vidData: vidData, callback: { (response, error) in
                Constant.appDelegate.hideProgressHUD()
                if error == nil {
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
                }
                else {
                    Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                }
            })
        }
        
        //    }while count < imagesData.count - 1
    }
}
extension albumPhotosVC: ConsentDelegate
{
    func selectedOption(sender: ConsentViewController, agree: Bool) {
        if agree
        {
            self.startSync()
        }
    }
}

