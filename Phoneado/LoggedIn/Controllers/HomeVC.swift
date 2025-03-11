//
//  HomeVC.swift
//  Phoneado
//
//  Created by Zimble on 3/25/22.
//

import UIKit
import Contacts
import ContactsUI
import ADCountryPicker
import Alamofire
import PhoneNumberKit
import TwilioVoice
import Photos
import CoreLocation
import SDWebImage

class HomeVC: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    //MARK: - IBOutlets
    @IBOutlet weak var syncBtnView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var homeTV: UITableView!
    @IBOutlet weak var contactsCountTF: UITextField!
    @IBOutlet weak var containerChildViews: UIView!
    @IBOutlet weak var galleryClickHighlightImgView: UIImageView!
    @IBOutlet weak var messageClickHighlightImgView: UIImageView!
    @IBOutlet weak var bottomTabbarView: UIView!
    @IBOutlet weak var bottomTabbarImgView: UIImageView!
    @IBOutlet weak var favouritesLbl: UILabel!
    @IBOutlet weak var myContactsLbl: UILabel!
    @IBOutlet weak var myContactsLblView: UIView!
    @IBOutlet weak var favouritesLblView: UIView!
    
    @IBOutlet weak var callLogsLblView: UIView!
    @IBOutlet weak var noRecordsLbl: UILabel!
    @IBOutlet weak var callLogsLbl: UILabel!
    
    //MARK: - Variable
    var buttonState = "notChecked"
    var selectionType: SelectionType = .none
    var favouritesBtnClicked = false
    var selectedIndexPaths = Set<IndexPath>()
    let contactStore = CNContactStore()
    let keys = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactPhoneNumbersKey,
        CNContactEmailAddressesKey
    ] as [Any]
    var contactName = [String]()
    let messagesVC = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
    let galleryVC = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryVC
    var arrayElementCount = [Int]()
    var elementAndCountDict = [String:Int]()
    var contacts = [Contact]()
    var orignalContacts = [Contact]()
    var favContacts = [Contact]()
    var orignafavContacts = [Contact]()
    var contactsWithSections = [[Contact]]()
    var searchedContact = [[Contact]]()
    var callLog = [CallLogs]()
    var myContactEnabled: Bool = true
    var callLogEnabled: Bool = false
    var isLoadMore: Bool = false
    var searchContact: String = ""
    let collation = UILocalizedIndexedCollation.current()
    // create a locale collation object, by which we can get section index titles of current locale. (locale = local contry/language)
    var sectionTitles = [String]()
    let globalQueue = DispatchQueue.global()
    
    private var sideMenuShadowView: UIView!
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var revealSideMenuOnTop: Bool = true
    var getContactsData: GetContactsData?
    var getfavContacts: GetContactsData?
    var originalGetfavContacts: GetContactsData?
    
    var getFavouriteContactsData: GetFavouriteContactsData?
    var userLoginType = ""
    
    var isViaSignup: Bool = Bool()
    var syncFromPhone = false
    var isFav: Bool = Bool()
    var userProfile: UserProfile!
    let locationManager = CLLocationManager()
    var lat: Double = 0.0
    var long: Double = 0.0
    //MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        
        self.checkApp()
        self.navigationController?.navigationBar.isHidden = true
        if self.userLoginType == "Admin" {
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.homeTV.register(UINib(nibName: "CallLogsTVC", bundle: nil), forCellReuseIdentifier: "CallLogsTVC")
        self.noRecordsLbl.isHidden = true
    }
    
    func checkApp() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        LoggedInRequest().checkVersion(versionStatus: appVersion!) { dict, error in
            if (error == nil) {
                let data = dict! as NSDictionary
                let optionalUpdate = data.value(forKey: "optionalUpdate") as! Bool
                let forceUpdate = data.value(forKey: "forceUpdate") as! Bool
                if(!optionalUpdate && !forceUpdate) {
                    print("Ignore")
                } else if(forceUpdate) {
                    self.showEmergencyAlert(message: data.value(forKey: "forceUpdateMessage") as! String)
                } else {
                    self.showAlert(message: data.value(forKey: "optionalUpdateMessage") as! String)
                }
            }
        }
    }
    
    func showEmergencyAlert(message: String) {
        let alertController = UIAlertController(title: "Time to update", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let url: URL = URL(string: "https://apps.apple.com/us/app/phoneado/id1635148075")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.checkApp()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Time to update", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let url: URL = URL(string: "https://apps.apple.com/us/app/phoneado/id1635148075")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Ignore", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectionType = .none
        selectedIndexPaths = []
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(signinNotificationHandler(notificationInfo:)),
                                               name: Notification.Name.SigninNotification,
                                               object: nil)
        Socketton.shared.establishConnection()
        self.generateTwilioVoiceToken()
        self.getUserProfile()
    }
    
    func generateTwilioVoiceToken() {
        LoggedInRequest().genrateTwilioVoiceToken(otherUserId: "") { response, error in
            if (response != nil) {
                let token = (response! as NSDictionary).value(forKey: "token") as! String
                Constant.appDelegate.twilioVoiceToken = token
                self.registerOnTwilio()
            }
        }
    }
    
    func registerOnTwilio() {
        TwilioVoiceSDK.register(accessToken: Constant.appDelegate.twilioVoiceToken, deviceToken:Constant.appDelegate.deviceTokenData!) { error in
            print("Twilio error", error?.localizedDescription ?? "")
        }
    }
    
    func getUserProfile() {
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getUserProfile(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let res: [String: Any] = response!["data"] as! [String : Any]
                let user = Storage.shared.readUser()
                user?.lastLocation = res["lastLocation"] as? LastLocation
                user?.isLocationUpdateRequired = res["isLocationUpdateRequired"] as? Bool
                user?.locationUpdateTime = res["locationUpdateTime"] as? Double
                
                Storage.shared.saveUser(user: user!)
                
                if self.userLoginType == "Admin" {
                    if res["isLocationUpdateRequired"] as? Bool ?? false {
                        LocationManager.shared.checkLocationAuthorization { (enable) in
                            if enable {
                                LocationManager.shared.intialiseLocationManager { (enable) in
                                    self.locationManager.requestAlwaysAuthorization()
                                    // For use in foreground
                                    self.locationManager.requestWhenInUseAuthorization()
                                    if CLLocationManager.locationServicesEnabled() {
                                        self.locationManager.delegate = self
                                        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                                        self.locationManager.startUpdatingLocation()
                                    }
                                }
                            } else {
                                let statuss = CLLocationManager.authorizationStatus()
                                if statuss == .notDetermined {
                                    LocationManager.shared.intialiseLocationManager { (enable) in
                                        self.locationManager.requestAlwaysAuthorization()
                                        // For use in foreground
                                        self.locationManager.requestWhenInUseAuthorization()
                                        if CLLocationManager.locationServicesEnabled() {
                                            self.locationManager.delegate = self
                                            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                                            self.locationManager.startUpdatingLocation()
                                        }
                                    }
                                } else {
                                    Alert().showAlertWithAction(title: "", message: "Please enable your Location Services", buttonTitle: "Enable", secondBtnTitle: "Cancel", withCallback: {
                                        if let bundleId = Bundle.main.bundleIdentifier,
                                           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        }
                                    }) {}
                                }
                            }
                        }
                    }
                }
            } else {
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
    
    //MARK: - Required Methods
    func initialViewSetup() {
        syncBtnView.layer.cornerRadius = syncBtnView.bounds.width / 2
        searchView.layer.cornerRadius = searchView.bounds.height / 2
        searchView.borderWidth = 1
        searchView.borderColor = UIColor.homeSearchViewBorderColor
        contactsCountTF.delegate = self
        if userLoginType == "" {
            let user = Storage.shared.readUser()
            self.userLoginType = user?.userLoginType ?? ""
        }
        if userLoginType == "Admin" {
            self.syncBtnView.isHidden = false
            self.getPhoneContact()
        } else {
            self.syncBtnView.isHidden = true
            self.favouritesLblView.isHidden = true
            getContactsRequest()
        }
        tableViewSetup()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.callLogEnabled {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                self.getSearchCallLogs(offset: 0, updatedText: updatedText)
            }
        } else {
            if let text = textField.text,
               let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                self.contacts = self.orignalContacts.filter({($0.givenName + " " + $0.familyName).lowercased().contains( updatedText.lowercased())})
                if (updatedText == "") {
                    self.contacts = self.orignalContacts
                }
                setUpCollation()
                homeTV.reloadData()
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func signinNotificationHandler(notificationInfo: Notification) {
        if let userInfo = notificationInfo.userInfo as? [String: Any] {
            if let userLoginType = userInfo["UserLoginType"] as? String {
                print("User Login Type = \(userLoginType)")
            }
        }
    }
    
    func getPhoneContact() {
        self.contacts.removeAll()
        Constant.appDelegate.showProgressSyncHUD(view: self.view)
        ContactManager.shared.fetchContacts { contactsData in
            self.contacts.removeAll()
            for contact in contactsData {
                let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                let email = contact.emailAddresses.first?.value ?? ""
                self.contacts.append(
                    Contact(
                        givenName: contact.givenName,
                        familyName: contact.familyName,
                        mobile: phoneNumber,
                        id: contact.identifier,
                        email: String(email),
                        contactType: contact.departmentName,
                        favourite: "false",
                        userId: "",
                        profilePic: "",
                        imageDataAvailable: contact.imageDataAvailable,
                        imageData: contact.imageData)
                )
                if self.contacts.count == contactsData.count {
                    self.setUpCollation()
                    Constant.appDelegate.hideProgressSyncHUD()
                    self.homeTV.reloadData()
                }
            }
            self.orignalContacts = self.contacts
            AllContacts = self.orignalContacts
            if self.userLoginType != "Admin" {
                self.getContactsRequest()
            } else {
                self.getContactsWithFavourites()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.callLogEnabled {
            let y = max(0.0, homeTV.contentOffset.y)
            let visibleCells = homeTV.visibleCells
            let topCell = visibleCells.first
            if topCell != nil {
                let indexPath = homeTV.indexPath(for: topCell!)
                // point for the top visible content
                let pt: CGPoint = CGPoint(x: 0, y: y)
                // Access the bottom point using pt
                let bottomPoint = CGPoint(x: pt.x, y: pt.y + homeTV.bounds.size.height)
                if self.isLoadMore {
                    let idx = homeTV.indexPathForRow(at: bottomPoint)
                    if idx != nil {
                        if idx!.row == self.callLog.count - 1 {
                            self.isLoadMore = false
                            let offset = self.callLog.count
                            self.getCallLogs(offset: offset)
                        }
                    }
                }
            }
        }
    }
    
    func isTableViewScrolling() -> Bool {
        return self.homeTV.isDragging || self.homeTV.isDecelerating
    }
    
    func stopTableViewScrolling() {
        let currentOffset = homeTV.contentOffset
        homeTV.setContentOffset(currentOffset, animated: false)
    }
    
    @objc func setUpCollation() {
        let (arrayContacts, arrayTitles) = collation.partitionObjects(array: self.contacts, collationStringSelector: #selector(getter: Contact.givenName))
        self.contactsWithSections = arrayContacts as! [[Contact]]
        self.sectionTitles = arrayTitles
        if self.sectionTitles.count > 0 {
            self.contactsCountTF.placeholder = "\(self.contacts.count) Contacts"
        } else {
            self.contactsCountTF.placeholder = "0 Contacts"
        }
    }
    
    func tableViewSetup() {
        homeTV.delegate = self
        homeTV.dataSource = self
        homeTV.showsVerticalScrollIndicator = false
        homeTV.register(UINib(nibName: "HomeContactsTVHeaderCell", bundle: nil), forCellReuseIdentifier: "HomeContactsTVHeaderCell")
        homeTV.register(UINib(nibName: "HomeContactsTVC", bundle: nil), forCellReuseIdentifier: "HomeContactsTVC")
        homeTV.reloadData()
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        DispatchQueue.main.async {
            self.addChild(viewController)
            self.containerChildViews.addSubview(viewController.view)
            viewController.view.frame = self.view.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.didMove(toParent: self)
        }
    }
    
    @objc func selectAllBtnHandler(sender: UIButton) {
        selectedIndexPaths = []
        if selectionType == .none {
            selectionType = .single
        } else if selectionType == .single {
            selectionType = .all
            for s in 0..<homeTV.numberOfSections {
                for i in 0..<homeTV.numberOfRows(inSection: s) {
                    selectedIndexPaths.insert(IndexPath(row: i, section: s))
                }
            }
        } else {
            selectionType = .single
            selectedIndexPaths = []
        }
        homeTV.reloadData()
    }
    
    @objc func selectBtnClick(sender: cellInfoBtn) {
        if let indexPath = sender.indexPath {
            if selectedIndexPaths.contains(indexPath) {
                selectedIndexPaths.remove(indexPath)
            } else {
                selectedIndexPaths.insert(indexPath)
            }
            checkAllSelected()
            homeTV.reloadData()
        }
    }
    
    func checkAllSelected() {
        let all = selectedIndexPaths.count == contacts.count
        if all {
            selectionType = .all
        } else {
            selectionType = .single
        }
    }
    
    @objc func addToFavouriteContactBtnHandler(sender: cellInfoBtn) {
        let indexPath = sender.indexPath
        let cell = homeTV.cellForRow(at: indexPath!) as! HomeContactsTVC
        print("IsFavourite = ", self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].isFavourite ?? "")
        var requestDict = [String: Any]()
        if cell.contactSelectImg.image == UIImage(named: "addedToFavContactIcon") {
            deleteFavouriteContactRequest(contactID: self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].id ?? "", requestParams: [:]) { messageString in
                if self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].isFavourite == "false" {
                    self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].isFavourite = "true"
                } else {
                    self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].isFavourite = "false"
                }
                self.homeTV.reloadData()
            }
        } else {
            requestDict = ["id": self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].id ?? ""]
            addToFavouriteContactRequest(requestParams: requestDict) { messageString in
                if self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].isFavourite == "false" {
                    self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].isFavourite = "true"
                } else {
                    self.contactsWithSections[sender.indexPath!.section][sender.indexPath!.row].isFavourite = "false"
                }
                self.homeTV.reloadData()
            }
        }
    }
    
    func getCallLogs(offset: Int) {
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getCallLogs(fromContactVC: false ,offset: offset, params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let res: [String: Any] = response!["data"] as! [String : Any]
                var calls: [CallLogs] = []
                let totalCount: Int = res["totalCount"] as! Int? ?? 0
                if let array: NSArray = res["callLogs"] as! NSArray? {
                    for post in array {
                        if let dict: [String:Any] = post as! [String:Any]? {
                            let call = CallLogs.init(dict)
                            calls.append(call)
                        }
                    }
                }
                if offset == 0 {
                    self.callLog = calls
                } else {
                    self.callLog.append(contentsOf: calls)
                }
                DispatchQueue.main.async {
                    if self.callLog.count > 0 {
                        self.noRecordsLbl.isHidden = true
                        self.contactsCountTF.placeholder = "\(self.callLog.count) Calls"
                    } else {
                        self.noRecordsLbl.isHidden = false
                        self.contactsCountTF.placeholder = "0 Calls"
                    }
                }
                self.isLoadMore = self.callLog.count < totalCount
                self.homeTV.reloadData()
            } else {
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong, please try again later.", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
    
    func getSearchCallLogs(offset: Int, updatedText: String) {
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getSearchCallLogs(fromContactVC: false, text: updatedText, offset: offset, params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                self.callLog.removeAll()
                let res: [String: Any] = response!["data"] as! [String: Any]
                var calls: [CallLogs] = []
                if let array: NSArray = res["callLogs"] as! NSArray? {
                    for post in array {
                        if let dict: [String: Any] = post as! [String: Any]? {
                            let call = CallLogs.init(dict)
                            calls.append(call)
                        }
                    }
                }
                self.callLog = calls
                DispatchQueue.main.async {
                    if self.callLog.count > 0 {
                        self.noRecordsLbl.isHidden = true
                        self.contactsCountTF.placeholder = "\(self.callLog.count) Calls"
                    } else {
                        self.noRecordsLbl.isHidden = false
                        self.contactsCountTF.placeholder = "0 Calls"
                    }
                }
                self.homeTV.reloadData()
            } else {
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong, please try again later.", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
    
    func getDate(date: Double) -> String {
        let predate = Date()
        let msgdate = date.dateFromTimeStamp().addingTimeInterval(0)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateToPrint: NSString = dateFormatter.string(from: msgdate ) as NSString
        let predateToPrint: NSString = dateFormatter.string(from: predate) as NSString
        
        if dateToPrint != predateToPrint {
            
            if Calendar.current.isDateInToday(dateFormatter.date(from: dateToPrint as String)!) {
                return  "Today"
            } else if Calendar.current.isDateInYesterday(dateFormatter.date(from: dateToPrint as String)!) {
                return  "Yesterday"
                
            } else if get_WeekDay(date: dateFormatter.date(from: dateToPrint as String)!) {
                dateFormatter.dateFormat = "EEEE"
                return  dateFormatter.string(from: (date.dateFromTimeStamp()))
            } else {
                dateFormatter.dateFormat = "MM/dd/yy"
                return  dateFormatter.string(from: (date.dateFromTimeStamp()))
            }
        } else if dateToPrint == predateToPrint {
            dateFormatter.dateFormat = " hh:mm a"
            return  dateFormatter.string(from: (date.dateFromTimeStamp()))
        }
        return "nil"
    }
    
    func  get_WeekDay(date: Date) -> Bool {
        let currentComponent = Calendar.current.component(.weekOfYear, from: Date())
        let component = Calendar.current.component(.weekOfYear, from: date)
        if currentComponent == component || currentComponent == component+1 {
            if  currentComponent == component + 1 {
                if Calendar.current.component(.weekday, from: Date()) < Calendar.current.component(.weekday, from: date){
                    return true
                } else {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    //MARK: - IB Actions
    @IBAction func syncBtnTapped(_ sender: Any) {
        if callLogEnabled || favouritesBtnClicked {
            Alert().showAlert(message: "Please go to my contacts to sync the contacts")
        } else {
            let vc = ConsentViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    func startSync() {
        if userLoginType == "Admin" {
            var requestDict: [String: [[String: Any]]] = ["contactList": []]
//            if selectionType == .none {
                var phoneNumberInfo = [[String: Any]]()
                for i in 0..<contacts.count {
                    let id = self.contacts[i].id ?? ""
                    let firstname = self.contacts[i].givenName ?? ""
                    let lastname = self.contacts[i].familyName ?? ""
                    let mobile = self.contacts[i].mobile ?? ""
                    let contactType = self.contacts[i].contactType ?? "home"
                    let email = self.contacts[i].email ?? ""
                    let phoneNumberInfoValues = ["key": contactType, "value": mobile]
                    phoneNumberInfo.append(phoneNumberInfoValues)
                    let contactList = [
                        "id": id,
                        "firstName": "\(firstname) \(lastname)",
                        "lastname": lastname,
                        "email": email,
                        "phoneNumber": phoneNumberInfo[i]
                    ] as [String: Any]
                    requestDict["contactList"]?.append(contactList)
                }
//            } else {
//                if selectedIndexPaths.count <= 0 {
//                    self.show(message: "Please select atleast one contact to sync.", controller: self)
//                    return
//                }
//                requestDict["contactList"] = selectedIndexPaths.map {
//                    let contact = contactsWithSections[$0.section][$0.row]
//                    let id = contact.id ?? ""
//                    let firstname = contact.givenName ?? ""
//                    let lastname = contact.familyName ?? ""
//                    let mobile = contact.mobile ?? ""
//                    let contactType = contact.contactType ?? "home"
//                    let email = contact.email ?? ""
//                    let phoneNumberInfoValues = ["key": contactType, "value": mobile]
//                    return [
//                        "id": id,
//                        "firstName": "\(firstname) \(lastname)",
//                        "lastname": lastname,
//                        "email": email,
//                        "phoneNumber": phoneNumberInfoValues
//                    ] as [String : Any]
//                }
//            }
            print("Contact Sync Request Dict = \(requestDict)")
            uploadContactsRequest(requestParams: requestDict)
        } else {
            self.show(message:"Guest cannot sync contacts.", controller: self)
        }
//        selectionType = .none
//        selectedIndexPaths = []
    }
    
    @IBAction func messagesTapped(_ sender: Any) {
        if self.isTableViewScrolling() {
            self.stopTableViewScrolling()
        }
        messageClickHighlightImgView.image = UIImage(named: "Icon_highlighter")
        messagesVC.userLoginType = self.userLoginType
        add(asChildViewController: messagesVC)
        galleryClickHighlightImgView.image = UIImage(named: "")
        bottomTabbarView.backgroundColor = .clear
        bottomTabbarImgView.backgroundColor = .clear
    }
    
    @IBAction func contactsTapped(_ sender: Any) {
//        selectionType = .none
//        selectedIndexPaths = []
        homeTV.reloadData()
        if self.isTableViewScrolling() {
            self.stopTableViewScrolling()
        }
        remove(asChildViewController: messagesVC)
        remove(asChildViewController: galleryVC)
        galleryClickHighlightImgView.image = UIImage(named: "")
        messageClickHighlightImgView.image = UIImage(named: "")
        bottomTabbarView.backgroundColor = .clear
        bottomTabbarImgView.backgroundColor = .clear
        self.getUserProfile()
    }
    
    @IBAction func galleryTapped(_ sender: Any) {
        if self.isTableViewScrolling() {
            self.stopTableViewScrolling()
        }
        galleryClickHighlightImgView.image = UIImage(named: "Icon_highlighter")
        galleryVC.userLoginType = self.userLoginType
        DispatchQueue.main.async {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.add(asChildViewController: self.galleryVC)
                } else if (newStatus == PHAuthorizationStatus.denied) {
                    self.add(asChildViewController: self.galleryVC)
                } else if (newStatus == PHAuthorizationStatus.notDetermined) {
                    self.add(asChildViewController: self.galleryVC)
                }
            })
        }
        messageClickHighlightImgView.image = UIImage(named: "")
        bottomTabbarView.backgroundColor = .clear
        bottomTabbarImgView.backgroundColor = .clear
    }
    
    @IBAction func favouritesTapped(_ sender: Any) {
        if self.isTableViewScrolling() {
            self.stopTableViewScrolling()
        }
        if userLoginType == "Admin" {
            getFavouritesRequest()
        }
    }
    
    @IBAction func myContactsTapped(_ sender: Any) {
//        selectionType = .none
//        selectedIndexPaths = []
        if self.isTableViewScrolling() {
            self.stopTableViewScrolling()
        }
        self.myContactEnabled = true
        self.callLogEnabled = false
        self.favouritesBtnClicked = false
        self.noRecordsLbl.isHidden = true
        if userLoginType == "Admin" {
            // MARK: prevent API recall using save Contacts
            self.contacts = AllContacts
            setUpCollation()
            self.homeTV.reloadData()
            getUserProfile()
        } else {
            getContactsRequest()
        }
        self.myContactsLbl.textColor = UIColor(named: "AppColor")
        self.favouritesLbl.textColor = UIColor(named: "DarkGrayTextColor")
        self.callLogsLbl.textColor = UIColor(named: "DarkGrayTextColor")
    }
    
    @IBAction func callLogsBtnTapped(_ sender: Any) {
        if self.isTableViewScrolling() {
            self.stopTableViewScrolling()
        }
        self.myContactEnabled = false
        self.callLogEnabled = true
        self.favouritesBtnClicked = false
        self.favouritesLbl.textColor = UIColor(named: "DarkGrayTextColor")
        self.myContactsLbl.textColor = UIColor(named: "DarkGrayTextColor")
        self.callLogsLbl.textColor = UIColor(named: "AppColor")
        self.getCallLogs(offset: 0)
    }
    
    @IBAction func sideMenuTapped(_ sender: Any) {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
        vc.userLoginType = self.userLoginType
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.callLogEnabled {
            return 1
        } else {
            if userLoginType == "Admin" {
                return sectionTitles.count
            } else {
                return sectionTitles.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.callLogEnabled {
            return self.callLog.count
        } else {
            if userLoginType == "Admin" {
                return contactsWithSections[section].count
            } else {
                return contactsWithSections[section].count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.callLogEnabled {
            let cell = self.homeTV.dequeueReusableCell(withIdentifier: "CallLogsTVC") as! CallLogsTVC
            
            if indexPath.row < self.callLog.count {
                let calls = self.callLog[indexPath.row]
                
                if calls.direction == "outbound-dial" {
                    cell.userNameLbl.text = calls.toDetails?.fullName
                    cell.incomingOrOutgoingLbl.text = "Outgoing Call"
                    cell.userNameLbl.textColor = UIColor.black
                    cell.userImageView.sd_setImage(with: URL(string: calls.toDetails?.profilePic ?? ""), placeholderImage: UIImage(named: "user"))
                } else {
                    cell.userNameLbl.text = calls.fromDetails?.fullName
                    cell.userImageView.sd_setImage(with: URL(string: calls.fromDetails?.profilePic ?? ""), placeholderImage: UIImage(named: "user"))
                    
                    if calls.status == "completed" {
                        cell.incomingOrOutgoingLbl.text = "Incoming Call"
                        cell.userNameLbl.textColor = UIColor.black
                    } else {
                        cell.incomingOrOutgoingLbl.text = "Missed Call"
                        cell.userNameLbl.textColor = UIColor.red
                    }
                }
                
                cell.dialVideoCallImageView.image = calls.type == "voice" ? UIImage(named: "call1") : UIImage(named: "video1")
                cell.dateLbl.text = self.getDate(date: calls.dateCreated ?? 0)
                cell.userImageView.applyCorner()
            } else {
                print("Error: Index out of range. callLog count: \(self.callLog.count), indexPath.row: \(indexPath.row)")
            }
            
//            let calls = self.callLog[indexPath.row]
//            
//            if calls.direction == "outbound-dial" {
//                cell.userNameLbl.text = calls.toDetails?.fullName
//                cell.incomingOrOutgoingLbl.text = "Outgoing Call"
//                cell.userNameLbl.textColor = UIColor.black
//                cell.userImageView.sd_setImage(with: URL(string: calls.toDetails?.profilePic ?? ""),placeholderImage: UIImage.init(named: "user"))
//            } else {
//                cell.userNameLbl.text = calls.fromDetails?.fullName
//                cell.userImageView.sd_setImage(with: URL(string: calls.fromDetails?.profilePic ?? ""),placeholderImage: UIImage.init(named: "user"))
//                if calls.status == "completed" {
//                    cell.incomingOrOutgoingLbl.text = "Incoming Call"
//                    cell.userNameLbl.textColor = UIColor.black
//                } else {
//                    cell.incomingOrOutgoingLbl.text = "Missed Call"
//                    cell.userNameLbl.textColor = UIColor.red
//                }
//            }
//            if calls.type == "voice" {
//                cell.dialVideoCallImageView.image = UIImage(named: "call1")
//            } else {
//                cell.dialVideoCallImageView.image = UIImage(named: "video1")
//            }
//            cell.dateLbl.text = self.getDate(date: calls.dateCreated ?? 0)
//            cell.userImageView.applyCorner()
            return cell
        } else {
            let cell = homeTV.dequeueReusableCell(withIdentifier: "HomeContactsTVC") as! HomeContactsTVC
            let contact = contactsWithSections[indexPath.section][indexPath.row]
            if userLoginType == "Admin" {
                cell.selectionStyle = .default
                cell.contactName?.text = contact.givenName + " " + contact.familyName
                cell.detailTextLabel?.text = contact.mobile
            } else {
                cell.selectionStyle = .default
                cell.contactName?.text = contact.givenName + " " + contact.familyName
                cell.detailTextLabel?.text = contact.mobile
            }
            if !((contact.profilePic ?? "").isEmpty) {
                cell.contactImg.sd_setImage(with: URL(string: contact.profilePic ?? ""),placeholderImage: UIImage.init(named: "user"))
            } else if contact.imageDataAvailable && contact.imageData != nil {
                cell.contactImg.image = UIImage.init(data: contact.imageData ?? Data() )
            } else {
                cell.contactImg.image = UIImage.init(named: "user")
            }
            cell.addToFavouriteContactBtn.indexPath = indexPath
            cell.addToFavouriteContactBtn.tag = indexPath.row
            cell.addToFavouriteContactBtn.addTarget(self, action: #selector(addToFavouriteContactBtnHandler(sender:)), for: .touchUpInside)
            cell.contactSelectImg.cornerRadius = cell.contactSelectImg.height / 2
//            if selectionType != .none && userLoginType == "Admin" && !favouritesBtnClicked {
//                cell.contactSelectImg.isHidden = true
//                cell.addToFavouriteContactBtn.removeTarget(self, action: #selector(addToFavouriteContactBtnHandler(sender:)), for: .touchUpInside)
//                cell.addToFavouriteContactBtn.addTarget(self, action: #selector(selectBtnClick(sender:)), for: .touchUpInside)
//                let selected = selectedIndexPaths.contains(indexPath)
//                let image = UIImage(named: selected ? "select" : "Oval")?.withRenderingMode(.alwaysOriginal)
//                cell.addToFavouriteContactBtn.setImage(image, for: .normal)
//            } else if userLoginType == "Admin" {
//                cell.contactSelectImg.isHidden = false
//                cell.addToFavouriteContactBtn.setImage(nil, for: .normal)
//                cell.addToFavouriteContactBtn.removeTarget(self, action: #selector(selectBtnClick(sender:)), for: .touchUpInside)
//                if !favouritesBtnClicked {
//                    cell.addToFavouriteContactBtn.addTarget(self, action: #selector(addToFavouriteContactBtnHandler(sender:)), for: .touchUpInside)
//                }
//                if contact.isFavourite == "true" {
//                    cell.contactSelectImg.image = UIImage(named: "addedToFavContactIcon")
//                } else {
//                    cell.contactSelectImg.image = UIImage(named: favouritesBtnClicked ? "" : "addToFavContactIcon")
//                }
//            } else {
//                cell.contactSelectImg.isHidden = true
//            }
            if contact.isFavourite == "true" {
                cell.contactSelectImg.image = UIImage(named: "addedToFavContactIcon")
            }else {
                cell.contactSelectImg.image = UIImage(named: "addToFavContactIcon")
            }
            if favouritesBtnClicked == true {
                cell.contactSelectImg.isHidden = true
            }else if favouritesBtnClicked == false {
                cell.contactSelectImg.isHidden = false
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HomeContactsTVHeaderCell") as! HomeContactsTVHeaderCell
        headerCell.tag = section
        if userLoginType == "Admin" {
            headerCell.alphabetsLbl.text = "\(sectionTitles[section])"
        } else {
            headerCell.alphabetsLbl.text = "\(sectionTitles[section])"
        }
        headerCell.selectAllBtn.addTarget(self, action: #selector(selectAllBtnHandler), for: .touchUpInside)
//        if section == 0 && userLoginType == "Admin" && !favouritesBtnClicked && !callLogEnabled {
//            if selectionType == .single {
//                headerCell.selectAllLbl.text = "Select All"
//                headerCell.selectAllImgView.image = UIImage(named: "Oval")
//            } else if selectionType == .all {
//                headerCell.selectAllLbl.text = "Select All"
//                headerCell.selectAllImgView.image = UIImage(named: "select")
//            } else {
//                headerCell.selectAllLbl.text = "Select"
//            }
//        } else {
            headerCell.selectAllLbl.isHidden = true
            headerCell.selectAllSelectionView.isHidden = true
//        }
        headerCell.selectAllStackView.layoutIfNeeded()
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.callLogEnabled {
            return 0
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.callLogEnabled {
            return 60
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.callLogEnabled {
            if indexPath.row < self.callLog.count {
                let contact = callLog[indexPath.row]
                let vc = ContactDetailsVC.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                
                if contact.direction == "outbound-dial" {
                    vc.contactName = "\(contact.toDetails?.fullName ?? "")"
                    vc.contactNumber = "\(contact.toDetails?.mobile ?? "")"
                    vc.profilePicUrl = contact.toDetails?.profilePic
                } else {
                    vc.contactName = "\(contact.fromDetails?.fullName ?? "")"
                    vc.contactNumber = "\(contact.fromDetails?.mobile ?? "")"
                    vc.profilePicUrl = contact.fromDetails?.profilePic
                }
                Constant.appDelegate.isButtonEnable = true
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            let contact = contactsWithSections[indexPath.section][indexPath.row]
            if contact.mobile != nil {
                let vc = ContactDetailsVC.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                
                vc.contactName = "\(contact.givenName + " " + contact.familyName)"
                vc.contactNumber = "\(contact.mobile ?? "")"
                vc.imageData = contact.imageData
                vc.imageDataAvailable = contact.imageDataAvailable
                vc.profilePicUrl = contact.profilePic
                Constant.appDelegate.isButtonEnable = true
                DispatchQueue.main.async {
                    if self.selectionType != .single && self.selectionType != .all {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}

extension UILocalizedIndexedCollation {
    func partitionObjects(array: [AnyObject], collationStringSelector: Selector) -> ([AnyObject], [String]) {
        var unsortedSections = [[AnyObject]]()
        //1. Create an array to hold the data for each section
        for _ in self.sectionTitles {
            unsortedSections.append([]) //appending an empty array
        }
        //2. Put each objects into a section
        for item in array {
            let index: Int = self.section(for: item, collationStringSelector:collationStringSelector)
            unsortedSections[index].append(item)
        }
        //3. sorting the array of each sections
        var sectionTitles = [String]()
        var sections = [AnyObject]()
        for index in 0 ..< unsortedSections.count { if unsortedSections[index].count > 0 {
            sectionTitles.append(self.sectionTitles[index])
            sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
        }
        }
        return (sections, sectionTitles)
    }
}

extension HomeVC {
    func uploadContactsRequest(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressSyncHUD(view: self.view)
        LoggedInRequest().uploadContactsRequest(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressSyncHUD()
            if error == nil {
                self.homeTV.reloadData()
                if let responseMessage = response?["data"] as? String {
                    // MARK: - Refresh contacts
                    self.getPhoneContact()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        Alert().showAlertWithAction(title: "Successfull", message: "\(responseMessage)", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
                    }
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    
    func getContactsRequest(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getContactsRequest(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                do {
                    let responseData = try JSONDecoder().decode(GetContactsData.self, from: data)
                    self.getContactsData = responseData
                    print("Get Contacts Response Data: ", self.getContactsData ?? [])
                    self.contacts.removeAll()
                    for i in 0..<(self.getContactsData?.contactList.count ?? 0) {
                        self.contacts.append(
                            Contact(
                                givenName: self.getContactsData?.contactList[i].firstName ?? "",
                                familyName: "",
                                mobile: self.getContactsData?.contactList[i].phoneNumber?[0].value ?? "",
                                id: self.getContactsData?.contactList[i].id ?? "",
                                email: self.getContactsData?.contactList[i].email ?? "",
                                contactType: "",
                                favourite: String(self.getContactsData?.contactList[i].isFavorite ?? false),
                                userId: self.getContactsData?.contactList[i].userId ?? "",
                                profilePic: self.getContactsData?.contactList[i].profilePic ?? ""
                            )
                        )
                    }
                } catch let err {
                    print("Err", err.localizedDescription)
                }
                self.setUpCollation()
                self.orignalContacts = self.contacts
                DispatchQueue.main.async {
                    self.homeTV.reloadData()
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                print("Error = \(error?.message ?? TextString.inValidResponseError)")
            }
        }
    }

    func getContactsWithFavourites(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getFavouritesRequest(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                do {
                    let favContacts = try JSONDecoder().decode(GetFavouriteContactsData.self, from: data)
                    
                    var favouriteNumbers: [String] = []
                    for i in 0..<favContacts.contactFavList.count {
                        favouriteNumbers.append(favContacts.contactFavList[i].phoneNumber[0].value ?? "")
                    }
                    self.mapFavouritesContact(numbers: favouriteNumbers)
                } catch {
                    print("Error: ", error)
                }
            }
        }
    }

    func mapFavouritesContact(numbers: [String]) {
        // FIXME: HACK - Fixed for freezing
        DispatchQueue.global(qos: .background).async {
            if numbers.count > 0 {
                let tempContacts = self.contacts
                for i in 0..<tempContacts.count {
                    if numbers.contains(where: { $0 == tempContacts[i].mobile }) {
                        tempContacts[i].isFavourite = "true"
                    }
                }
                DispatchQueue.main.async {
                    if self.myContactEnabled {
                        self.contacts = tempContacts
                    }
                    AllContacts = tempContacts
                    self.setUpCollation()
                    self.homeTV.reloadData()
                }
            }
        }
    }
 
    func getFavouritesRequest(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getFavouritesRequest(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                do {
                    let responseData = try JSONDecoder().decode(GetFavouriteContactsData.self, from: data)
                    self.getFavouriteContactsData = responseData
                    self.contacts.removeAll()
                    for i in 0..<(self.getFavouriteContactsData?.contactFavList.count ?? 0) {
                        self.contacts.append(Contact(
                            givenName: self.getFavouriteContactsData?.contactFavList[i].firstName ?? "",
                            familyName: "",
                            mobile: self.getFavouriteContactsData?.contactFavList[i].phoneNumber[0].value ?? "",
                            id: self.getFavouriteContactsData?.contactFavList[i].id ?? "",
                            email: self.getFavouriteContactsData?.contactFavList[i].email ?? "",
                            contactType: "",
                            favourite: String(self.getContactsData?.contactList[i].isFavorite ?? false),
                            userId: self.getFavouriteContactsData?.contactFavList[i].userId ?? "",
                            profilePic: self.getFavouriteContactsData?.contactFavList[i].profilePic ?? "")
                        )
                    }
                } catch let err {
                    print("Err", err.localizedDescription)
                }
                self.setUpCollation()
                DispatchQueue.main.async {
                    self.homeTV.reloadData()
                }
                // MARK: make favourites selected if exists value
                self.favouritesBtnClicked.toggle()
                self.callLogEnabled = false
                self.myContactEnabled = false
                self.noRecordsLbl.isHidden = true
                self.myContactsLbl.textColor = UIColor(named: "DarkGrayTextColor")
                self.favouritesLbl.textColor = UIColor(named: "AppColor")
                self.callLogsLbl.textColor = UIColor(named: "DarkGrayTextColor")
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                print("Error = \(error?.message ?? TextString.inValidResponseError)")
            }
        }
    }
    
    func addToFavouriteContactRequest(requestParams: [String: Any] = [:], callback: @escaping (String) -> ()) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().addToFavouriteContactRequest(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                if let responseMessage = response?["data"] as? String {
                    callback(responseMessage)
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    
    func deleteFavouriteContactRequest(contactID: String, requestParams: [String: Any] = [:], callback: @escaping (String) -> ()) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().deleteFavouriteContactRequest(contactID: contactID, params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                if let responseMessage = response?["data"] as? String {
                    callback(responseMessage)
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}

extension HomeVC: ConsentDelegate {
    func selectedOption(sender: ConsentViewController, agree: Bool) {
        if agree {
//            if selectedIndexPaths.count > 0 {
                self.startSync()
//            } else {
//                selectionType = .single
//                self.homeTV.reloadData()
//            }
        }
    }
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.lat = locValue.latitude
        self.long = locValue.longitude
    }
}

@objc class Contact: NSObject {
    @objc var givenName: String!
    @objc var familyName: String!
    @objc var mobile: String!
    @objc var id: String!
    @objc var userId: String!
    @objc var email: String!
    @objc var contactType: String!
    @objc var isFavourite: String!
    @objc var profilePic: String!
    var imageDataAvailable: Bool
    @objc var imageData: Data?
    
    init(givenName: String, familyName: String, mobile: String, id: String, email: String, contactType: String, favourite: String, userId: String,profilePic: String, imageDataAvailable: Bool = false, imageData: Data? = nil) {
        self.givenName = givenName
        self.familyName = familyName
        self.mobile = mobile
        self.id = id
        self.email = email
        self.userId = userId
        self.contactType = contactType
        self.isFavourite = favourite
        self.profilePic = profilePic
        self.imageDataAvailable = imageDataAvailable
        self.imageData = imageData
    }
}

extension String {
    var keepNumbers: String {
        return String(describing: filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "+0123456789")) != nil })
    }
}

enum SelectionType {
    case none
    case single
    case all
}
