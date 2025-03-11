//
//  AppDelegate.swift
//  Phoneado
//
//  Created by Zimble on 3/23/22.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD
import Firebase
import PushKit
import CallKit
import TwilioVideo
import FirebaseMessaging
import GoogleMaps
import MediaPlayer
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window:UIWindow?
    var hud: MBProgressHUD?
    var checkForIncomingCall: Bool = true
    var userIsHolding: Bool = true
    var deviceTokenData: Data?
    var twilioVoiceToken: String = String()
    var notificationDict: [String: Any]!
    var audioDevice: DefaultAudioDevice = DefaultAudioDevice()
    var currentTimeZone: String = String()
    var isViaBooking: Bool = Bool()
    var lastNotifcaion: UNNotification!
    
    var isButtonEnable: Bool = Bool()
    var userType: String = String()
    
    var isCallingViewOpen: Bool = Bool()
    var isCallingVideoViewOpen: Bool = Bool()
    var currentVideoCallID: String = String()
    var player: AVAudioPlayer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ShowRootViewController()
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        TwilioVideoSDK.audioDevice = DefaultAudioDevice()
        setupFirebaseForDIfferentEnviroments()
        self.registerForRemoteNotifcation(application)
        isButtonEnable = true
        GMSServices.provideAPIKey("AIzaSyAsVrHxXGITDH-g6ozMNeoEAtiFuhGulwI")
        
        return true
    }
    
    func registerForRemoteNotifcation(_ application: UIApplication) {
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
    }
    
    func setupFirebaseForDIfferentEnviroments() {
        var plistName:String!
#if DEV
        plistName = "GoogleService-InfoDev"
#else
        plistName = "GoogleService-Info"
#endif
        let filePath = Bundle.main.path(forResource: plistName, ofType: "plist")
        let fileopts = FirebaseOptions(contentsOfFile: filePath!)
        if fileopts != nil{
            FirebaseApp.configure(options: fileopts!)
        } else {
            FirebaseApp.configure()
        }
        
    }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.applicationDidBecomeActive
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}
extension AppDelegate {
    
    //MARK: - Progress Methods
    func showProgressHUD(view : UIView)->Void {
        
        DispatchQueue.main.async {
            if self.hud != nil {
                self.hud?.removeFromSuperview()
                self.hud = nil
            }
            self.hud = MBProgressHUD(view: view)
            guard let hud = self.hud else {
                return
            }
            hud.label.text = "Loading..."
            hud.contentColor = UIColor.black
            view.addSubview(hud)
            hud.show(animated: true)
        }
    }
    //MARK: hideProgressHUD Method
    func hideProgressHUD() {
        if hud != nil {
            hud?.hide(animated: true)
            DispatchQueue.main.async {
                self.hud?.removeFromSuperview()
            }
            hud = nil
        }
    }
    
    func showProgressSyncHUD(view : UIView)->Void{
        if hud != nil {
            hud?.removeFromSuperview()
            hud = nil
        }
        hud = MBProgressHUD(view: view)
        DispatchQueue.main.async {
            guard let hud = self.hud else {
                return
            }
            hud.label.text = "Contact's are syncing ..."
            hud.contentColor = UIColor.black
            view.addSubview(hud)
            hud.show(animated: true)
        }
    }
    //MARK: hideProgressHUD Method
    func hideProgressSyncHUD(){
        if hud != nil {
            hud?.hide(animated: true)
            DispatchQueue.main.async {
                self.hud?.removeFromSuperview()
            }
            hud = nil
        }
    }
    func ShowRootViewController() {
        if !(Storage().getUserId()?.isEmpty)! {
            let user: UserDetail = Storage().readUser()!
            if let userId = user.userId {
                if !userId.isEmpty {

                    LoginIfUserIsThere()
                }else {
                    let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                    let introNvC = UINavigationController(rootViewController: vc)
                    introNvC.navigationItem.backBarButtonItem = .none
                    self.window?.rootViewController = introNvC
                    self.window?.makeKeyAndVisible()
                }
            }
        }
        else
        {
            let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            let introNvC = UINavigationController(rootViewController: vc)
            introNvC.navigationBar.isHidden = true
            self.window?.rootViewController = introNvC
            self.window?.makeKeyAndVisible()
        }
    }
    func LoginIfUserIsThere() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyBoard = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil)
        
        let type = Storage.shared.isAdminUser()
        let viewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        viewController.userLoginType = type!
        let introNvC = UINavigationController(rootViewController: viewController)
        self.window?.rootViewController = introNvC
        self.window?.makeKeyAndVisible()
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
        let userInfo = response.notification.request.content.userInfo
        self.notificationDict = (userInfo as! [String: Any])
        
        if(self.notificationDict != nil){
        
            if(self.notificationDict["type"] as? String != nil) {

                
                if(self.notificationDict["type"] as! String == "INCOMING_CALL" || self.notificationDict["type"] as! String == "INCOMING_GROUP_CALL") {
                    
                    if #available(iOS 13.0, *) {
                          let scene = UIApplication.shared.connectedScenes.first
                           if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                            sd.openVideoViewController(dict:self.notificationDict)
                        }
                    }
                    
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: "disable"), object:nil,userInfo:nil)

                    isButtonEnable = false
                    
                    
                 }else if(self.notificationDict["type"] as! String == "ANSWER_CALL"){
                   NotificationCenter.default.post(name:NSNotification.Name(rawValue: "myCall"), object:nil,userInfo: self.notificationDict!)
                     NotificationCenter.default.post(name:NSNotification.Name(rawValue: "enable"), object:nil,userInfo:nil)
                     isButtonEnable = false

                 }
                 else if (self.notificationDict["type"] as! String == "DISCONNECT"){
                     
                     
                     if Constant.appDelegate.currentVideoCallID == self.notificationDict["callerId"] as! String {
                         
                         NotificationCenter.default.post(name:NSNotification.Name(rawValue: "cancelCall"), object:nil,userInfo: self.notificationDict!)
                          NotificationCenter.default.post(name:NSNotification.Name(rawValue: "enable"), object:nil,userInfo:nil)
                          isButtonEnable = true
                     }
                     
                }
        
        else if (self.notificationDict["type"] as! String == "newMessage"){
            let vc = IndividualChatDetailVC.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
            vc.toID = self.notificationDict["senderId"] as? String
            vc.individualName = self.notificationDict["userName"] as? String ?? ""
            vc.isViaDetail = true
            UIApplication.getTopViewController()?.navigationController?.pushViewController(vc, animated: true)
                              
                }
                
            }

            
        }
                
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        if( UIApplication.shared.applicationState == .active){
            
            if(notification.request.content.userInfo["type"] as? String != nil){
                
                if(notification.request.content.userInfo["type"] as! String == "CUSTOM"){
                    completionHandler([.alert, .badge, .sound])
                    
                    print("Not Silent Notification")
                    
                }else{
                    print(notification.request.content.userInfo["type"] as! String)
                    
                    if(notification.request.content.userInfo["type"] as! String == "ringPhone"){
                        self.playSound()
                    }else if (notification.request.content.userInfo["type"] as? String == "newMessage" || (notification.request.content.userInfo["type"] as? String == "chat")) && (UIApplication.getTopViewController() as? HomeVC != nil){
                        
                        if (Constant.appDelegate.isCallingVideoViewOpen || Constant.appDelegate.isCallingViewOpen){
                            //ignore
                        }else{
                            NotificationCenter.default.post(name: Notification.Name.reloadMessages, object: nil, userInfo:nil)
                            completionHandler([.alert, .badge, .sound])
                        }
                        
                    }else if (notification.request.content.userInfo["type"] as! String == "newMessage") && (UIApplication.getTopViewController() as? IndividualChatDetailVC != nil) && currentChatUserId == notification.request.content.userInfo["senderId"] as? String {
                        
                    }else{
                        
                        if (notification.request.content.userInfo["type"] as! String == "DISCONNECT"){
                            
                            completionHandler([])
                            
                        }else{
                            if (Constant.appDelegate.isCallingVideoViewOpen || Constant.appDelegate.isCallingViewOpen){
                                if (notification.request.content.userInfo["type"] as! String == "INCOMING_CALL"){
                                    
                                    completionHandler([])
                                    
                                } else if (notification.request.content.userInfo["type"] as! String == "newMessage") {
                                    completionHandler([])
                                } else {
                                    completionHandler([.alert, .badge, .sound])
                                }
                            } else {
                                completionHandler([.alert, .badge, .sound])
                            }
                        }
                    }
                    print("Silent Notification")
                }
            }
        }
//        else if( UIApplication.shared.applicationState == .background) {
//            NotificationCenter.default.post(name: Notification.Name("enterBackground"), object: nil, userInfo: nil)
//            }
        else {
            print("else not Silent Notification")
            completionHandler([])
        }
        }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
            Messaging.messaging().apnsToken = deviceToken
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                Messaging.messaging().token { toke, error in
                    if let error = error {
                        print("Error fetching remote instance ID: \(error)")
                    } else  {
                        SaveToken.deviceToken = toke ?? ""
                    }
                }
            })
            print(deviceToken)
        }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    
    func pushView(){
        if #available(iOS 13.0, *) {
              let scene = UIApplication.shared.connectedScenes.first
              if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                  sd.pushView()
              }
          }
    }

    
    func playSound() {
        do {  try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            guard let path = Bundle.main.path(forResource: "siren1", ofType:"mp3") else {
                return }
            let url = URL(fileURLWithPath: path)
            
            if ((player?.isPlaying) != nil){
                player?.stop()
            }
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            player?.volume = 100
            
            
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    func playSoudsss(){
        do {
            try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)

            try AVAudioSession.sharedInstance().setActive(true)
            
           let songTitle = "siren"
         let   songExtension = "mp3"
           if let url = Bundle.main.url(forResource: "\(songTitle)", withExtension: "\(songExtension)"){
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.play()
            }
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    
    
}


extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM TOKEN: ===> \(fcmToken ?? "")")
    }

}

//let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
extension String {
    public init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}
