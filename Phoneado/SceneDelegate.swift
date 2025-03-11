//
//  SceneDelegate.swift
//  Phoneado
//
//  Created by Zimble on 3/23/22.
//

import UIKit
import SocketIO
import UserNotifications
import FirebaseMessaging
import PushKit
import CallKit
import Firebase
import TwilioVoice
import CoreLocation

protocol PushKitEventDelegate: AnyObject {
    func credentialsUpdated(credentials: PKPushCredentials) -> Void
    func credentialsInvalidated() -> Void
    func incomingPushReceived(payload: PKPushPayload) -> Void
    func incomingPushReceived(payload: PKPushPayload, completion: @escaping () -> Void) -> Void
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate,UNUserNotificationCenterDelegate,PKPushRegistryDelegate,CXProviderDelegate {
    var window: UIWindow?
    var provider: CXProvider! = nil
    var voipRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
    let update = CXCallUpdate()
    let reason = CXCallEndedReason.remoteEnded
    var payLoadDict:NSDictionary!
    var pushKitEventDelegate: PushKitEventDelegate?
    var voiceCallVC:VoiceCallVC!

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        
        window?.overrideUserInterfaceStyle = .light
        guard let _ = (scene as? UIWindowScene) else { return }
        TwilioVoiceSDK.audioDevice = DefaultAudioDevice()

        ShowRootViewController()
        initializePushKit()

    }
    func sceneDidDisconnect(_ scene: UIScene) {
        Socketton.shared.closeConnection()
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        if let user: UserDetail = Storage().readUser() {
            if let userId = user.userId {
                if !userId.isEmpty {
                    //Socketton.shared.establishConnection()
                    let status = CLLocationManager.authorizationStatus()
                    if status == .authorizedAlways || status == .authorizedWhenInUse
                    {
                        if user.isLocationUpdateRequired ?? false
                        {
                            LocationManager.shared.startLocationUpdation()
                        }else
                        {
                            LocationManager.shared.stopUpdatingLocation()
                        }
                    } else {
                        LocationManager.shared.stopUpdatingLocation()
                    }
                } else {
                    
                }
            }
        }

        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        Socketton.shared.closeConnection()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    func ShowRootViewController()
    {
        
        self.credentialsInvalidated()
//        self.ShowUpdateLocationViewController()
        if !(Storage().getUserId()?.isEmpty)! {
            let user: UserDetail = Storage().readUser()!
            if let userId = user.userId {
                if !userId.isEmpty {
//                    guard let windowScene = scene as? UIWindowScene else { return }
                    let Hvc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController (withIdentifier: "HomeVC") as! HomeVC
                    
                    let type = Storage.shared.isAdminUser()
                    Hvc.userLoginType = type!

                    let HomeNvC = UINavigationController(rootViewController: Hvc)
//                     window = UIWindow(windowScene: windowScene)
                     window?.rootViewController = HomeNvC
                     window?.makeKeyAndVisible()
                }else {
//                    guard let windowScene = scene as? UIWindowScene else { return }
                    let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController (withIdentifier: "SignInVC") as! SignInVC
                    let loginNvC = UINavigationController(rootViewController: vc)
//                     window = UIWindow(windowScene: windowScene)
                     window?.rootViewController = loginNvC
                     window?.makeKeyAndVisible()
                }
            }
        }
        else
        {
//            guard let windowScene = scene as? UIWindowScene else { return }
//            let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController (withIdentifier: "SignInVC") as! SignInVC
//             window = UIWindow(windowScene: windowScene)
//             window?.rootViewController = vc
//             window?.makeKeyAndVisible()
            
            let vc = SignInVC.loadViewController(withStoryBoard: StoryBoardName.authentication)
            let loginNvC = UINavigationController(rootViewController: vc)
            loginNvC.navigationBar.isHidden = true
            self.window?.rootViewController = loginNvC
        }
    }
    
    func openSignUpVC()
    {
        let vc = SignInVC.loadViewController(withStoryBoard: StoryBoardName.authentication)
        let loginNvC = UINavigationController(rootViewController: vc)
        loginNvC.navigationBar.isHidden = true
        self.window?.rootViewController = loginNvC
    }
    
    func openVideoViewController(dict: [String: Any]) {
        let navController: UINavigationController = self.window?.rootViewController as! UINavigationController
        let veryFirstScreen = VideoVC()
        veryFirstScreen.anohterUserDict = dict
        veryFirstScreen.celeName = dict["fullName"] as! String
        navController.pushViewController(veryFirstScreen, animated: true)
    }
    
    func openVoiceController(dict: NSDictionary){
        let navController: UINavigationController = self.window?.rootViewController as! UINavigationController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoggedIn", bundle: nil)
        let veryFirstScreen = mainStoryboard.instantiateViewController(withIdentifier: "VoiceCallVC") as! VoiceCallVC
        veryFirstScreen.isViaNotification = true
        veryFirstScreen.notificationDict = dict
        navController.pushViewController(veryFirstScreen, animated: true)
       
    }
    
    func pushView(){
        let navController:UINavigationController = self.window?.rootViewController as! UINavigationController
        navController.pushViewController(voiceCallVC, animated: true)
    }
    
    func initializePushKit() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        NSLog("VoIP Token: \(pushCredentials.token)")
        Constant.appDelegate.deviceTokenData = pushCredentials.token
        
        let token = String(deviceToken: pushCredentials.token)
        print(token)

        
    }
    
    func credentialsInvalidated() {
    
        if (Constant.appDelegate.twilioVoiceToken != ""){
            
            TwilioVoiceSDK.unregister(accessToken: Constant.appDelegate.twilioVoiceToken, deviceToken: Constant.appDelegate.deviceTokenData!) { error in
                if let error = error {
                    NSLog("An error occurred while unregistering: \(error.localizedDescription)")
                } else {
                    NSLog("Successfully unregistered from VoIP push notifications.")
                }
            }
        }

    }

   
   func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
       NSLog("pushRegistry:didReceiveIncomingPushWithPayload:forType:")
       

       if (Constant.appDelegate.isCallingViewOpen || Constant.appDelegate.isCallingViewOpen){
           
           //Ignore
       }else{
           
           let dict =  payload.dictionaryPayload as NSDictionary
           let name = dict.value(forKey: "twi_from") as! String
           
           let str =   dict.value(forKey: "twi_params") as! String
           
           let query  = str.queryDictionary
           
           //NotificationCenter.default.post(name:NSNotification.Name(rawValue: "disable"), object:nil,userInfo:nil)
          // Constant.appDelegate.isButtonEnable = false
           
           NotificationCenter.default.post(name:NSNotification.Name(rawValue: "disable"), object:nil,userInfo:nil)
           Constant.appDelegate.isButtonEnable = false

           
           let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoggedIn", bundle: nil)
           voiceCallVC = (mainStoryboard.instantiateViewController(withIdentifier: "VoiceCallVC") as! VoiceCallVC)
           self.pushKitEventDelegate = voiceCallVC
           voiceCallVC.initaiteVoiceCall(dict: query!)
           voiceCallVC.voiceCallVC = voiceCallVC

           
           if let delegate = self.pushKitEventDelegate {
               delegate.incomingPushReceived(payload: payload)
           }
       }
       

   }

    
   
   func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
       NSLog("pushRegistry:didInvalidatePushTokenForType:")
       
       if let delegate = self.pushKitEventDelegate {
           delegate.credentialsInvalidated()
       }
   }
   
    
    func removeProvider(){
        
        if((self.provider) != nil){
            self.provider = nil
        }
    }
    
    func providerDidReset(_ provider: CXProvider) {
        
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {

        self.provider.reportCall(with: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, endedAt: nil, reason: reason)
       
        if #available(iOS 13.0, *) {
              let scene = UIApplication.shared.connectedScenes.first
               if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                   sd.openVoiceController(dict:self.payLoadDict)
            }
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {

//         let bookingID = self.notificationDict["bookingId"] as! String
//        TWILIOAPI.cancelCallByCelebrity(isCancel: "yes", bookingId:bookingID, success: { (resposne) in
//            print(resposne)
//
//        }, failure: { (error) in
//
//            print(error)
//        })
//        action.fulfill()
    }

}
extension String {
    var queryDictionary: [String: String]? {

        var queryStrings = [String: String]()
        for pair in self.components(separatedBy: "&") {

            let key = pair.components(separatedBy: "=")[0]

            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""

            queryStrings[key] = value
        }
        return queryStrings
    }
}

