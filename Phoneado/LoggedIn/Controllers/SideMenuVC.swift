//
//  SideMenuVC.swift
//  Phoneado
//
//  Created by Zimble on 4/8/22.
//

import UIKit
import PanSlip
import SDWebImage
import CoreLocation

class SideMenuVC: UIViewController {
    //MARK: - Variable
    @IBOutlet var versionLbl: UILabel!
    var gesture : UITapGestureRecognizer?
    //MARK: - IB Outlet
    @IBOutlet weak var menuDismissBtn: UIButton!
    @IBOutlet weak var sidemenuTV: UITableView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var logoutBackView: UIView!
    @IBOutlet weak var logoutLabel: UILabel!
    
    var sectionMenu = ["Profile Settings", "Change Pin","Delete Account"]
    var sectionMenuImages = ["User-1", "Change Pin", "delete_icon"]
    var userLoginType: String = ""
    var type:String = String()
    let locationManager = CLLocationManager()
    var lat: Double = 0.0
    var long: Double = 0.0
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        // Do any additional setup after loading the view.
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        NotificationCenter.default.addObserver(self,selector: #selector(closeView), name: NSNotification.Name("CloseView"), object: nil)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeView(_:)))
        menuDismissBtn.addGestureRecognizer(gesture)
        self.gesture = gesture
        sidemenuTV.delegate = self
        sidemenuTV.dataSource = self
        sidemenuTV.register(UINib(nibName: "SideMenuTVC", bundle: nil), forCellReuseIdentifier: "SideMenuTVC")
        sidemenuTV.register(UINib(nibName: "MainMenuTVC", bundle: nil), forCellReuseIdentifier: "MainMenuTVC")
        sidemenuTV.register(UINib(nibName: "SectionMenuTVC", bundle: nil), forCellReuseIdentifier: "SectionMenuTVC")
        logoutLabel.font = UIFont.appFontMedium(size: 16)
        logoutLabel.textColor = .greyTextColor
        logoutLabel.text = "Logout"
        
        logoutBackView.addGestureRecognizer(GetTapGesture())
        addSwipe()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.buildVersionNumber
        self.versionLbl.text = "V \(appVersion!)(\(buildNumber!))"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sidemenuTV.reloadData()
    }
    
    func getTapOnLoactionNew() -> UITapGestureRecognizer{
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTap4))
        tapGesture.cancelsTouchesInView = false
        tapGesture.view?.tag  = 1009
        return tapGesture
        
    }
    func getTapOnLoaction() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTap3))
        tapGesture.cancelsTouchesInView = false
        tapGesture.view?.tag  = 1004
        return tapGesture

    }
    @objc func viewTap3(gesture: UITapGestureRecognizer)
    {
      

    }
    
    @objc func viewTap4(gesture: UITapGestureRecognizer)
    {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "MapViewVC") as! MapViewVC
        vc.modalPresentationStyle = .fullScreen

        self.present(vc, animated: true, completion: nil)


    }
    
    @objc func switchBtnAction(sender: UISwitch)
    {
        print("Switch btn action")
        
        if self.userLoginType == "Admin"
        {
            if sender.isOn == false
            {
                print("Off")
    //            sender.isOn = false
                LoggedInRequest().updateUser(params: ["location":["lat":self.lat,"lng":self.long], "isLocationUpdateRequired": false]) { (response, error) in
                    if error == nil
                    {
                        let user = Storage.shared.readUser()
                        user?.isLocationUpdateRequired = response?["isLocationUpdateRequired"] as? Bool
                        user?.lastLocation = response?["lastLocation"] as? LastLocation
                        Storage.shared.saveUser(user: user!)
                        self.sidemenuTV.reloadData()
                        LocationManager.shared.stopUpdatingLocation()
                        self.locationManager.stopUpdatingLocation()
                    }else{
                        Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
                    }
                }
            }else
            {
                print("On")
    //            sender.isOn = true
                LoggedInRequest().updateUser(params: ["isLocationUpdateRequired": true]) { (response, error) in
                    if error == nil
                    {
                        print("response?isLocationUpdateRequired", response?["isLocationUpdateRequired"] as? Bool)
                        print("response?lastLocation as? LastLocation", response?["lastLocation"] as? LastLocation)
                        let user = Storage.shared.readUser()
                        user?.isLocationUpdateRequired = response?["isLocationUpdateRequired"] as? Bool
                        user?.lastLocation = response?["lastLocation"] as? LastLocation
                        Storage.shared.saveUser(user: user!)
                        self.sidemenuTV.reloadData()
                        if self.userLoginType == "Admin"{
                            
                            LocationManager.shared.checkLocationAuthorization { (enable) in
                                if enable{
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
                                               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
                                            {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }) {
                                            LoggedInRequest().updateUser(params: ["isLocationUpdateRequired": false]) { (response, error) in
                                                if error == nil
                                                {
                                                    let user = Storage.shared.readUser()
                                                    user?.isLocationUpdateRequired = response?["isLocationUpdateRequired"] as? Bool
                                                    user?.lastLocation = response?["lastLocation"] as? LastLocation
                                                    Storage.shared.saveUser(user: user!)
                                                    self.sidemenuTV.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                    else
                    {
                        Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
                    }
                }
            }

  
        }
    }
    
    func getTap() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTap))
        tapGesture.cancelsTouchesInView = false
        tapGesture.view?.tag  = 1001
        return tapGesture
    }
    
    func getTapNew() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTap2))
        tapGesture.cancelsTouchesInView = false
        tapGesture.view?.tag  = 1002
        return tapGesture
    }
    
    @objc func viewTap2(gesture: UITapGestureRecognizer)
    {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "TermsAndConditionsVC") as! TermsAndConditionsVC
        vc.modalPresentationStyle = .fullScreen
        vc.type = "Terms & Conditions"

        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func viewTap(gesture: UITapGestureRecognizer)
    {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "TermsAndConditionsVC") as! TermsAndConditionsVC
        vc.modalPresentationStyle = .fullScreen
        vc.type = "Privacy Policy"
        self.present(vc, animated: true, completion: nil)
    }
    
    func GetTapGesture() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }
    
    @objc func viewTapHandler(gesture: UITapGestureRecognizer)
    {
        Alert().showAlertWithAction(title: "", message: "Are you sure you want to logout.", buttonTitle: "Logout", secondBtnTitle: "Cancel", withCallback: {
            Storage().clearAllCachedData()
            LocationManager.shared.stopUpdatingLocation()
            Constant.sceneDelegate?.ShowRootViewController()
        }, withCancelCallback: {})
        
    }
    @objc private func closeView(_ tapGestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    func addSwipe() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
            gesture.direction = direction
            sideMenuView.addGestureRecognizer(gesture)
        }
    }
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        print(sender.direction)
        if sender.direction == .left {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
// MARK: - UITableViewDataSource,UITableViewDelegate
extension SideMenuVC: UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.userLoginType == "Admin"
        {
            return 6
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainMenuTVC") as! MainMenuTVC
        if self.userLoginType == "Admin"
        {
        switch (section) {
        case 0:
            return UIView()
        case 1:
            cell.titleLabel.font = UIFont.appFontMedium(size: 14)
            cell.titleLabel.textColor = .greyTextColor
            cell.titleLabel.text = "Settings"
            cell.iconImageView.image = UIImage.init(named: "Settings")
            cell.arrowImageVIew.isHidden = true
            cell.switchBtn.isHidden = true
        
        case 2:
            cell.titleLabel.font = UIFont.appFontMedium(size: 14)
            cell.titleLabel.textColor = .greyTextColor
            cell.titleLabel.text = "Track Location"
            cell.iconImageView.image = UIImage.init(named: "track_location")
            cell.arrowImageVIew.isHidden = true
            self.type = "Track Location"
            cell.addGestureRecognizer(getTapOnLoaction())
            cell.switchBtn.isHidden = false
            let user = Storage.shared.readUser()
            print("user?.isLocationUpdateRequired ", user?.isLocationUpdateRequired )
            cell.switchBtn.isOn = user?.isLocationUpdateRequired ?? false
            cell.switchBtn.addTarget(self, action: #selector(switchBtnAction), for: .touchUpInside)
            
        case 3:
            cell.titleLabel.font = UIFont.appFontMedium(size: 14)
            cell.titleLabel.textColor = .greyTextColor
            cell.titleLabel.text = "Privacy Policy"
            cell.iconImageView.image = UIImage.init(named: "Terms")
            cell.arrowImageVIew.isHidden = true
            self.type = "Privacy Policy"
            cell.switchBtn.isHidden = true

            cell.addGestureRecognizer(getTap())
            
        case 4:
            cell.titleLabel.font = UIFont.appFontMedium(size: 14)
            cell.titleLabel.textColor = .greyTextColor
            cell.titleLabel.text = "Terms & Conditions"
            self.type = "Terms & Conditions"
            cell.iconImageView.image = UIImage.init(named: "Terms")
            cell.arrowImageVIew.isHidden = true
            cell.switchBtn.isHidden = true

            cell.addGestureRecognizer(getTapNew())
            
        default:
            return UIView()
        }
        }else{
            switch (section) {
            case 0:
                return UIView()
            case 1:
                cell.titleLabel.font = UIFont.appFontMedium(size: 14)
                cell.titleLabel.textColor = .greyTextColor
                cell.titleLabel.text = "Find Phone"
                cell.iconImageView.image = UIImage.init(named: "track_location")
                cell.arrowImageVIew.isHidden = true
                self.type = "Track Location"
                cell.addGestureRecognizer(getTapOnLoactionNew())
                cell.switchBtn.isHidden = true
                cell.switchBtn.addTarget(self, action: #selector(switchBtnAction), for: .touchUpInside)
            default:
                return UIView()
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        case 1:
            return 50
        case 2:
            return 0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userLoginType == "Admin"
        {
            switch section {
            case 0:
                return 1
            case 1:
                return self.sectionMenu.count
            case 2:
                return 0
            default:
                return 0
            }
        }else
        {
            switch section {
            case 0:
                return 1
            case 1:
                return 0
            case 2:
                return 0
            default:
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = sidemenuTV.dequeueReusableCell(withIdentifier: "SideMenuTVC", for: indexPath) as? SideMenuTVC
            
            cell?.userNameLabel.font = UIFont.appFontMedium(size: 14)
            cell?.userNumberLabel.font = UIFont.appFontMedium(size: 12)
            cell?.userNameLabel.textColor = .greyTextColor
            cell?.userNumberLabel.textColor = .greyTextColor
            
            let user = Storage.shared.readUser()
            cell?.userNameLabel.text = "\(user?.fullName ?? "")"
            cell?.userNumberLabel.text = "\(user?.mobile ?? "")"
            cell?.userImageView.layer.cornerRadius =     cell!.userImageView.frame.size.width/2
            if let picString: String = user?.profilePic, !picString.isEmpty
            {
                cell?.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell?.userImageView.sd_setImage(with: URL.init(string: picString), completed: nil)
            }
            
            
            return cell ?? UITableViewCell()
        case 1:
            let cell = sidemenuTV.dequeueReusableCell(withIdentifier: "SectionMenuTVC", for: indexPath) as? SectionMenuTVC
            cell?.arrowImageVIew.isHidden = false
            cell?.titleLabel.font = UIFont.appFontMedium(size: 12)
            cell?.titleLabel.textColor = .greyTextColor
            cell?.titleLabel.text = self.sectionMenu[indexPath.row]
            cell?.iconImageView.image = UIImage.init(named: "\(self.sectionMenuImages[indexPath.row])")
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
            
        case 2:
            return UITableViewCell()
        default:
            return UITableViewCell()
            
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1
        {
            if indexPath.row == 0{
                let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "ProfileSettingVC") as! ProfileSettingVC
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else if indexPath.row == 1{
                let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "ChangePinVC") as! ChangePinVC
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            else if indexPath.row == 2{
                
                Alert().showAlertWithAction(title: "", message: "Are you sure you want to delete your account? You will lose all your synced data", buttonTitle: "Delete", secondBtnTitle: "Cancel", withCallback: {
                    Constant.appDelegate.showProgressHUD(view: self.view)
                    LoggedInRequest().deleteApp { respone, error in
                        
                        if (error == nil){
                            
                            Storage().clearAllCachedData()
                            LocationManager.shared.stopUpdatingLocation()
                            Constant.sceneDelegate?.ShowRootViewController()

                        }
                        Constant.appDelegate.hideProgressHUD()
                    }
                    
                }, withCancelCallback: {})
            }
        }
    }
}
extension Bundle {

    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }

}

extension SideMenuVC: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("delegate called")
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.lat = locValue.latitude
        self.long = locValue.longitude
    }
}
