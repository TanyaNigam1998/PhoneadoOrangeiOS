//
//  ViewController.swift
//  VideoCallKitQuickStart
//
//  Copyright © 2016-2019 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioVideo
import CallKit
import AVFoundation

class ViewController: BaseViewController {
    //MARK: - IBOutlets
   @IBOutlet var upperCancelBtn: UIButton!
   @IBOutlet var upperView: UIView!
   @IBOutlet var timerLbl: UILabel!
   @IBOutlet weak var disconnectButton: UIButton!
   @IBOutlet weak var messageLabel: UILabel!
   @IBOutlet weak var micButton: UIButton!
   @IBOutlet weak var previewView: VideoView!

    var player: AVAudioPlayer?
    var accessToken = "TWILIO_ACCESS_TOKEN"
    var room: Room?
    
    var roomName: String = String()
    var roomSid: String = String()

    var bookingId: String = String()
    var celeName: String = String()
    var cID: String = String()
    var timerValue: Int = Int()

    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    var remoteView: VideoView?

    // CallKit components
    let callKitProvider: CXProvider! = nil
    let callKitCallController: CXCallController! = nil
    var callKitCompletionHandler: ((Bool)->Swift.Void?)? = nil
    var userInitiatedDisconnect: Bool = false
    
    var  cameraType: String = String()
    var timer: Timer!
    var newTimerValue: Int = Int()
    var ringerTime: Timer!
    var anohterUserDict: [String: Any]!
    
    var BothConnected: Bool = Bool()
    var ringtonePlayer: AVAudioPlayer? = nil

    var date: String = String()
    var isViaAlert: Bool = Bool()
    var isConnectingCall: Bool = Bool()
    
    func isAlreadyOnCall() {
        Socketton.shared.isOnAnotherCall = { json in
            print(json)
            print("Another Call Json = \(json)")
            if self.viewIfLoaded?.window != nil {
               let chat = ChatData(json)
                if chat.senderId == self.cID{
                    if (self.ringerTime != nil){
                        self.ringerTime.invalidate()
                        self.timerValue = 0
                    }
                    let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "alert", ofType: "mp3")!)
                    
                    do {
                        
                        if (self.player != nil){
                            self.player?.stop()
                        }
                        
                        self.ringtonePlayer = try AVAudioPlayer(contentsOf: ringtonePath)
                        self.ringtonePlayer?.delegate = self
                        self.ringtonePlayer?.numberOfLoops = -1
                        self.ringtonePlayer?.volume = 1.0
                        self.ringtonePlayer?.play()
                        self.isViaAlert = true
                    } catch {
                    }

                }
            }
        }
    }
    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        Constant.appDelegate.isCallingVideoViewOpen = true
       // self.isAlreadyOnCall()
        self.messageLabel.isHidden = true
        self.timerLbl.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Calling..."
        self.navigationItem.setHidesBackButton(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(connectMyCall), name: NSNotification.Name(rawValue: "myCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelCall), name: NSNotification.Name(rawValue: "cancelCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelCallonQuitMode), name: NSNotification.Name(rawValue: "cancelCallQuitMode"), object: nil)
    
       cameraType = "front"
       self.disconnectButton.isHidden = true
       self.micButton.isHidden = false
        if(self.bookingId != "") {
          self.upperView.isHidden = false
          self.playSound()
          self.previewView.frame = CGRect(x: self.view.frame.origin.x, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 330)
          self.startPreview()
          self.createRoom()
          self.view.bringSubviewToFront(previewView)
          self.view.bringSubviewToFront(upperCancelBtn)
         
          newTimerValue = 15
          ringerTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playTimerChecker), userInfo: nil, repeats: true)
        } else {
            self.previewView.frame = CGRect(x: self.view.frame.origin.x, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 330)
            self.navigationItem.title = "Connecting..."

            self.upperView.isHidden = true
            self.anotheuserConnectCall()
        }
        
        if(self.timer != nil) {
            timer.invalidate()
        }
        if(self.ringerTime != nil){
          //  self.ringerTime.invalidate()
        }
        
       // self.view.bringSubviewToFront(self.navBar)
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.view.backgroundColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        Constant.appDelegate.isCallingVideoViewOpen = false
        self.player?.pause()
        self.navigationController?.setNavigationBarHidden(true, animated:true)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "myCall"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "cancelCall"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "cancelCallQuitMode"), object: nil)
    
    }
    
    func runTimer() {
        
        if(timer != nil){
            timer.invalidate()
            timer = nil
        }
        if(self.ringerTime != nil){
            self.ringerTime.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playTimer), userInfo: nil, repeats: true)
    }
    
    
    func playSound() {
        let path = Bundle.main.path(forResource: "old_phone.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.currentTime = 0
            player?.volume = 3.0
            player?.numberOfLoops =  10
            player?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    @objc func playTimerChecker() {
        newTimerValue = newTimerValue - 1
        if(newTimerValue == 0){
            if(!BothConnected){
               
                self.player?.pause()
                if(timer != nil){
                    timer.invalidate()

                }
                
                if let room = room{
                    logMessage(messageText: "Attempting to disconnect from room \(room.name)")
                }
                
                userInitiatedDisconnect = true
                 if let room = room{
                  room.disconnect()
                }
                if(self.bookingId != ""){
                    print("cancel call 1")
                    Constant.appDelegate.currentVideoCallID =  ""

                    self.cancelCallFinal(isCancel: "no", bookingId: self.bookingId, email: "test@gmail.com", timeLeft: timerValue)
                }else{
                    let bookingID =  self.anohterUserDict["bookingId"] as! String
                    print("cancel call 2")
                    Constant.appDelegate.currentVideoCallID =  ""

                    self.cancelCallFinal(isCancel: "no", bookingId: bookingID, email: "test@gmail.com", timeLeft: timerValue)
                }
                
            }
        }
    }
    
    @objc func playTimer() {
    /*    timerValue = timerValue - 1
        let seconds = (timerValue) % 60
        let minutes = ((timerValue) / 60) % 60
        let hour = timerValue / 3600

        if(hour > 0){
            
            let time = String(format: "%0.2d:%0.2d:%0.2d",hour,minutes,seconds)
             self.navigationItem.rightBarButtonItem = nil
            let logButton : UIBarButtonItem = UIBarButtonItem(title:time, style: UIBarButtonItem.Style.plain, target: self, action:nil)
            self.navigationItem.rightBarButtonItem = logButton
            
            }else{
            let time = String(format: "%0.2d:%0.2d",minutes,seconds)
            self.navigationItem.rightBarButtonItem = nil
           let logButton : UIBarButtonItem = UIBarButtonItem(title:time, style: UIBarButtonItem.Style.plain, target: self, action:nil)
            self.navigationItem.rightBarButtonItem = logButton
        }
        
        print("Timer:::::\(timerValue)")
        
        if(timerValue == 0){
            timer.invalidate()
            if let room = room{
                logMessage(messageText: "Attempting to disconnect from room \(room.name)")
            }
            
            userInitiatedDisconnect = true
             if let room = room{
              room.disconnect()
            }
            if(self.bookingId != ""){
                 print("cancel call 3")
                self.cancelCallFinal(isCancel: "no", bookingId: self.bookingId, email: "test@gmail.com", timeLeft: timerValue)
            }else{
                 print("cancel call 4")
                let bookingID =  self.anohterUserDict["bookingId"] as! String
                self.cancelCallFinal(isCancel: "no", bookingId:bookingID, email:"test@gmail.com", timeLeft: timerValue)
            }
        } */
        
    }
    
    func createRoom() {
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().createRoomVideo(otherUserId: self.bookingId) { (response, error) in
            if error == nil {
                self.accessToken = response!["token"] as? String ?? ""
                self.roomName = response!["roomName"] as? String ?? ""
                self.roomSid = response!["roomSid"] as? String ?? ""
                Constant.appDelegate.hideProgressHUD()
                self.connectMyCall()
            }
        }
    }
    
     @objc private func cancelCallonQuitMode(notification: NSNotification) {
        if(self.bookingId != "") {
             print("cancel call 6")
            Constant.appDelegate.currentVideoCallID =  ""

            self.cancelCallFinal(isCancel: "no", bookingId: self.bookingId, email: "test@gmail.com", timeLeft: timerValue)
        } else {
             print("cancel call 7")
            if(self.anohterUserDict != nil) {
                let bookingID = self.anohterUserDict["callerId"] as! String
                Constant.appDelegate.currentVideoCallID =  ""
                self.cancelCallFinal(isCancel: "no", bookingId: bookingID, email: "test@gmail.com", timeLeft: timerValue)
            }
        }
    }
    
    @objc private func cancelCall(notification: NSNotification) {
        if(self.navigationController != nil) {
            
            if((self.timer) != nil){
                timer.invalidate()
            }
            if(self.ringerTime != nil){
                self.ringerTime.invalidate()
            }
            let user = Storage.shared.readUser()
            let userLoginType = user?.userLoginType ?? ""
            if userLoginType == "Admin" {
               // self.navigationController?.popViewController(animated: true)
                let arr = self.navigationController?.viewControllers
                if (arr != nil){
                    if (arr!.count > 0){
                        for controller in arr!{
                            if controller.isKind(of: HomeVC.classForCoder()){
                                self.navigationController?.popToViewController(controller, animated: true)
                            }
                        }
                    }
                }
            } else {
                Storage().clearAllCachedData()
                LocationManager.shared.stopUpdatingLocation()
                Constant.sceneDelegate?.ShowRootViewController()
            }
        } else {
            if((self.timer) != nil) {
                timer.invalidate()
            }
            if(self.ringerTime != nil) {
                self.ringerTime.invalidate()
            }
            let user = Storage.shared.readUser()
            let userLoginType = user?.userLoginType ?? ""
            if userLoginType == "Admin" {
                self.dismiss(animated: true, completion: nil)
            } else {
                Storage().clearAllCachedData()
                LocationManager.shared.stopUpdatingLocation()
                Constant.sceneDelegate?.ShowRootViewController()
            }
        }
    }
    
    @objc private func connectMyCall(notification: NSNotification? = nil) {
        self.prepareLocalMedia()
        self.navigationItem.title = "Ringing..."

        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = ConnectOptions(token: self.accessToken) { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
            builder.roomName = self.roomName
            //builder.uuid = uuid
        }
        
        // Connect to the Room using the options we provided.
        self.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
        self.logMessage(messageText: "Attempting to connect to room \(String(describing: self.roomName))")
        self.showRoomUI(inRoom: true)
    }
    
    func anotheuserConnectCall() {
        let bookingID = self.anohterUserDict["receiverId"] as! String
        self.roomSid = self.anohterUserDict["roomSid"] as! String
        self.roomName = self.anohterUserDict["roomName"] as! String
        self.timerValue = Int(self.anohterUserDict["timerValue"] as? String ?? "60")!
         self.connectCall(bookingID: bookingID, email: "test@throne.com")
    }

    func connectCall(bookingID: String, email: String) {
        self.startPreview()
        print("Comin Connect Call")
        
        let str = "otherUserId=\(bookingID)&roomName=\(self.roomName)&roomSid=\(self.roomSid)"
        LoggedInRequest().getVideoToken(otherUserId: str) { (response, error) in
            print(response)
             self.accessToken = (response! as NSDictionary).value(forKey: "token") as! String
                Constant.appDelegate.hideProgressHUD()
            // Prepare local media which we will share with Room Participants.
                self.prepareLocalMedia()
                // Preparing the connect options with the access token that we fetched (or hardcoded).
                let connectOptions = ConnectOptions(token: self.accessToken) { (builder) in
                    
                    // Use the local media that we prepared earlier.
                    builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
                    builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
                    builder.roomName = self.roomName
                    //builder.uuid = uuid
                }
                // Connect to the Room using the options we provided.
                self.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
                self.logMessage(messageText: "Attempting to connect to room \(String(describing: self.roomName))")
                self.showRoomUI(inRoom: true)
        }
    }

    func cancelCallFinal(isCancel: String, bookingId: String, email: String, timeLeft: Int) {
        
        if let room = self.room {
            room.disconnect()
        }
        self.cleanupRemoteParticipant()
        self.room = nil
        self.showRoomUI(inRoom: false)
        self.callKitCompletionHandler = nil
        self.camera = nil
        self.localAudioTrack = nil
        self.localVideoTrack = nil
        self.remoteParticipant = nil
        self.remoteView?.removeFromSuperview()
        self.remoteView = nil
        
        print("everything goes nil")
        if(self.timer != nil) {
            timer.invalidate()
        }
        
        if(self.ringerTime != nil) {
            self.ringerTime.invalidate()
        }
        
        if (self.roomSid == "") {
            if(self.navigationController != nil) {
                let arr = self.navigationController?.viewControllers
                if (arr != nil) {
                    if (arr!.count > 0) {
                        for controller in arr! {
                            if controller.isKind(of: HomeVC.classForCoder()) {
                                self.navigationController?.popToViewController(controller, animated: true)
                            }
                        }
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        var str = ""
        if self.bookingId != "" {
            str = "otherUserId=\(self.bookingId)&roomName=\(self.roomName)&roomSid=\(self.roomSid)"
        } else {
            str = "otherUserId=\(self.anohterUserDict["callerId"] ?? "")&roomName=\(self.roomName)&roomSid=\(self.roomSid)"
        }
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().endCall(otherUserId: str) { (response, error) in
            if error == nil {
                self.cleanupRemoteParticipant()
                self.room = nil
                self.showRoomUI(inRoom: false)
                self.callKitCompletionHandler = nil
                self.camera = nil
                self.localAudioTrack = nil
                self.localVideoTrack = nil
                self.remoteParticipant = nil
                self.remoteView?.removeFromSuperview()
                self.remoteView = nil
                
                let user = Storage.shared.readUser()
                let userLoginType = user?.userLoginType ?? ""
                if userLoginType == "Admin" {
                    if(self.navigationController != nil) {
                        let arr = self.navigationController?.viewControllers
                        if (arr != nil){
                            if (arr!.count > 0){
                                for controller in arr! {
                                    if controller.isKind(of: HomeVC.classForCoder()) {
                                        self.navigationController?.popToViewController(controller, animated: true)
                                    }
                                }
                            }
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    Storage().clearAllCachedData()
                    LocationManager.shared.stopUpdatingLocation()
                    Constant.sceneDelegate?.ShowRootViewController()
                }
                Constant.appDelegate.hideProgressHUD()
            } else {
                Constant.appDelegate.hideProgressHUD()
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.room != nil
    }
    
    @IBAction func uparCalcelClicked(_ sender: UIButton) {
        Constant.appDelegate.showProgressHUD(view: self.view)
        print("cancel call 5")
        
        if(self.timer != nil) {
            timer.invalidate()
        }
        
        if(self.ringerTime != nil) {
            self.ringerTime.invalidate()
        }
        Constant.appDelegate.currentVideoCallID =  ""

        self.cancelCallFinal(isCancel: "yes", bookingId: self.bookingId, email:"test@gmail.com", timeLeft: timerValue)
    }

    func setupRemoteVideoView() {
        print("In remote view")
        self.messageLabel.isHidden = true
        self.remoteView = VideoView(frame: self.view.frame, delegate: self)
        self.view.insertSubview(self.remoteView!, at: 0)
        self.remoteView!.contentMode = .scaleAspectFill
        
        let centerX = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteView!,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: self.view,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteView!,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: self.view,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
        print("done remote view")
        
        if(self.bookingId != "") {
            self.player?.pause()
            self.player = nil
            self.ringerTime.invalidate()
            self.upperView.isHidden = true
            
            self.previewView.frame = CGRect(x: self.view.frame.size.width - 130 , y:100, width: 125, height: 160)
            self.runTimer()
            self.navigationItem.title = self.celeName
        } else {
            self.runTimer()
            self.previewView.frame = CGRect(x: self.view.frame.size.width - 130 , y:100, width: 125, height: 160)
            if(self.anohterUserDict != nil) {
                let name = self.anohterUserDict["fullName"] as! String
                self.navigationItem.title = name
            }
        }
        Constant.appDelegate.hideProgressHUD()
    }

    @IBAction func disconnect(sender: AnyObject) {
        if let room = room {
            logMessage(messageText: "Attempting to disconnect from room \(room.name)")
            userInitiatedDisconnect = true
            room.disconnect()
            
            if(self.timer != nil) {
                timer.invalidate()
            }
            if(self.ringerTime != nil) {
                self.ringerTime.invalidate()
            }
            
            if(self.bookingId != "") {
                 print("cancel call 6")
                self.cancelCallFinal(isCancel: "no", bookingId: self.bookingId, email: "test@gmail.com", timeLeft: timerValue)
            } else {
                 print("cancel call 7")
                let bookingID = self.anohterUserDict["callerId"] as! String
                self.cancelCallFinal(isCancel: "no", bookingId: bookingID, email: "test@gmail.com", timeLeft: timerValue)
            }
        }
    }
    
    @IBAction func cameraFlipClicked(_ sender: UIButton) {
        self.flipCamera()
    }
    
    @IBAction func toggleMic(sender: AnyObject) {
        if let _ = room,let localAudioTrack = self.localAudioTrack {
            let isMuted = localAudioTrack.isEnabled
            localAudioTrack.isEnabled = !isMuted
            if (!isMuted) {
                self.micButton.setImage(UIImage(named:"Microphone-1"), for: .normal)
            } else {
                self.micButton.setImage(UIImage(named:"Microphone_mute"), for: .normal)
            }
        }
    }

    func startPreview() {
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)
        
        print("Comin Connect Call start preview")
        
        if (frontCamera != nil || backCamera != nil) {
          print("Comin Connect Call start preview camera not nil")
            
            let options = CameraSourceOptions { (builder) in
                // To support building with Xcode 10.x.
                #if XCODE_1100
                if #available(iOS 13.0, *) {
                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
                    print("Comin Connect Call start preview camera not nil 1")

                }
                #endif
            }
            // Preview our local camera track in the local video preview view.
            camera = CameraSource(options: options, delegate: self)
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")

            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)
            logMessage(messageText: "Video track created")
            print("Comin Connect Call start preview camera not nil add preview")


            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    print("Comin Connect Call start preview camera not nil error")
                    self.startPreview()
                } else {
                    self.previewView.shouldMirror = (captureDevice.position == .front)
                    print("Comin Connect Call start preview camera not nil fromt")
                }
            }
        } else {
            self.flipCamera()
            self.logMessage(messageText: "No front or back capture device found!")
        }
    }

    @objc func flipCamera() {
        var newDevice: AVCaptureDevice?

        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }

            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        self.logMessage(messageText: "Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    } else {
                        self.previewView.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
    }

    func prepareLocalMedia() {
        if (localAudioTrack == nil) {
            localAudioTrack = LocalAudioTrack()

            if (localAudioTrack == nil) {
                logMessage(messageText: "Failed to create audio track")
            }
        }
        if (localVideoTrack == nil) {
            self.startPreview()
        }
    }

    func showRoomUI(inRoom: Bool) {

        self.micButton.isHidden = !inRoom
        self.disconnectButton.isHidden = !inRoom
        
        if (self.anohterUserDict != nil) {
            Constant.appDelegate.currentVideoCallID =  self.anohterUserDict["receiverId"] as! String
        }
        UIApplication.shared.isIdleTimerDisabled = inRoom
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    func renderRemoteParticipant(participant: RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        
        print("Come in video part")
        
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack,
                publication.isTrackSubscribed {
                print("going to setupview")

                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.remoteView!)
                self.remoteParticipant = participant
                return true
            }
        }
        return false
    }

    func renderRemoteParticipants(participants : Array<RemoteParticipant>) {
        for participant in participants {
            // Find the first renderable track.
            if participant.remoteVideoTracks.count > 0,
                renderRemoteParticipant(participant: participant) {
                break
            }
        }
    }

    func cleanupRemoteParticipant() {
        if self.remoteParticipant != nil {
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
            self.remoteParticipant = nil
        }
    }
    
    func logMessage(messageText: String) {
        NSLog(messageText)
        self.messageLabel.isHidden = true
        if(messageLabel != nil) {
        }
    }

    func holdCall(onHold: Bool) {
        localAudioTrack?.isEnabled = !onHold
        localVideoTrack?.isEnabled = !onHold
    }
}

// MARK: - RoomDelegate
extension ViewController : RoomDelegate {
    func roomDidConnect(room: Room) {
        logMessage(messageText: "Connected" )
        for remoteParticipant in room.remoteParticipants {
            remoteParticipant.delegate = self
        }
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        
        logMessage(messageText: "Disconnected")
        
        print("Coming..... room disconnect")
        self.cleanupRemoteParticipant()
        if let room = self.room{
            room.disconnect()
        }
        self.cleanupRemoteParticipant()
        self.room = nil
        self.showRoomUI(inRoom: false)
        self.callKitCompletionHandler = nil
        self.camera = nil
        self.localAudioTrack = nil
        self.localVideoTrack = nil
        self.remoteParticipant = nil
        self.remoteView?.removeFromSuperview()
        self.remoteView = nil
        
        if(self.timer != nil) {
            timer.invalidate()
        }
        if(self.ringerTime != nil) {
            self.ringerTime.invalidate()
        }
        let user = Storage.shared.readUser()
        let userLoginType = user?.userLoginType ?? ""
        if userLoginType == "Admin" {
            
            let arr = self.navigationController?.viewControllers
            if (arr != nil){
                if (arr!.count > 0){
                    for controller in arr!{
                        if controller.isKind(of: HomeVC.classForCoder()) {
                            self.navigationController?.popToViewController(controller, animated: true)
                        }
                    }
                }
            }
        } else {
            Storage().clearAllCachedData()
            LocationManager.shared.stopUpdatingLocation()
            Constant.sceneDelegate?.ShowRootViewController()
        }
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        
        logMessage(messageText: "Failed to connect")
        self.room = nil
        self.showRoomUI(inRoom: false)
    }

    func roomIsReconnecting(room: Room, error: Error) {
          logMessage(messageText: "Reconnecting...")
    }

    func roomDidReconnect(room: Room) {
        //logMessage(messageText: "Reconnected to room \(room.name)")
         logMessage(messageText: "Reconnecting...")
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        // Listen for events from all Participants to decide which RemoteVideoTrack to render.
        participant.delegate = self

        logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("Go Goa Gone")
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")

    }
    
}

// MARK: - RemoteParticipantDelegate
extension ViewController : RemoteParticipantDelegate {
    func participantparticipantparticipantparticipantparticipant(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) published video track")
    }

    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) unpublished video track")
    }
    
    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.
        
        logMessage(messageText: "Participant \(participant.identity) published audio track")
    }

    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) unpublished audio track")
    }
    
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // The LocalParticipant is subscribed to the RemoteParticipant's video Track. Frames will begin to arrive now.

        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")

        if (self.remoteParticipant == nil) {
            _ = renderRemoteParticipant(participant: participant)
        }
    }

    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.

        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")

        if self.remoteParticipant == participant {
            cleanupRemoteParticipant()

            // Find another Participant video to render, if possible.
            if var remainingParticipants = room?.remoteParticipants,
                let index = remainingParticipants.firstIndex(of: participant) {
                remainingParticipants.remove(at: index)
                renderRemoteParticipants(participants: remainingParticipants)
            }
        }
    }

    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.

        logMessage(messageText: "Subscribed to audio track for Participant \(participant.identity)")
    }
    
    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
        logMessage(messageText: "Unsubscribed from audio track for Participant \(participant.identity)")
    }
    
    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled video track")
    }
    
    func remoteParticipantNetworkQualityLevelDidChange(participant: RemoteParticipant, networkQualityLevel: NetworkQualityLevel) {
        
    }
    
    func didUnsubscribeFromDataTrack(dataTrack: RemoteDataTrack, publication: RemoteDataTrackPublication, participant: RemoteParticipant) {
        
    }
    
    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled video track")
    }
    
    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled audio track")
    }
    
    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled audio track")
    }

    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }

    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK: - VideoViewDelegate
extension ViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK: - CameraSourceDelegate
extension ViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        logMessage(messageText: "Camera source failed with error: \(error.localizedDescription)")
    }
}

extension UIApplication {
    class var statusBarBackgroundColor: UIColor? {
        get {
            return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
        } set {
            (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
        }
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
            if (self.isViaAlert){
                
                Constant.appDelegate.currentVideoCallID =  ""
                self.cancelCallFinal(isCancel: "yes", bookingId: self.bookingId, email:"test@gmail.com", timeLeft: timerValue)
            }
            
            NSLog("Audio player finished playing successfully");
        } else {
            NSLog("Audio player finished playing with some error");
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            NSLog("Decode error occurred: \(error.localizedDescription)")
        }
    }
}
