//
//  VideoVC.swift
//  Phoneado
//
//  Created by Tanya Nigam on 25/02/25.
//

import UIKit
import AVFoundation
import TwilioVideo
import CallKit
import Foundation

class VideoVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var callDuration: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewView: VideoView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var disconnectBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Variables
    var camera: CameraSource?
    var player: AVAudioPlayer?
    var accessToken = "TWILIO_ACCESS_TOKEN"
    var room: Room?
    
    var roomName: String = String()
    var roomSid: String = String()
    var otherUserId: String = String()
    
    var bookingId: String = String()
    var celeName: String = String()
    var cID: String = String()
    var timerValue: Int = Int()
    var callStartTime: Date?
    var timerRunning = false
    private var isMobileBluetoothConnected = false
    private var isMobileWiredHeadsetConnected = false
    
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipants: Array<RemoteParticipant> = [] {
        didSet {
            let usersCount = remoteParticipants.count
            if usersCount != 1 && usersCount % 2 == 1 {
                previewView.isHidden = true
            } else {
                if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? RemoteVideoCVC {
                    localVideoTrack?.removeRenderer(cell.videoView!)
                }
                previewView.isHidden = false
            }
            updateNavigationTitle()
            collectionView.reloadData()
        }
    }
    
    /// CallKit components
    let callKitProvider: CXProvider! = nil
    let callKitCallController: CXCallController! = nil
    var callKitCompletionHandler: ((Bool)->Swift.Void?)? = nil
    var userInitiatedDisconnect: Bool = false
    
    var cameraType: String = String()
    var timer: Timer!
    var callDurationSeconds = 0
    var newTimerValue: Int = Int()
    var ringerTime: Timer!
    var anohterUserDict: [String: Any]!
    
    var bothConnected: Bool = Bool()
    var ringtonePlayer: AVAudioPlayer? = nil
    
    var date: String = String()
    var isViaAlert: Bool = Bool()
    var isConnectingCall: Bool = Bool()
    var isSpeakerEnabled = true
    var contacts = [Contact]()
    var userListData = [MobileList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        contacts = AllContacts
        getContactList()
        setupAudioSession()
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(callDeinitialise(_:)),
//                                               name: Notification.Name("enterBackground"),
//                                               object: nil)
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
        
        callDuration.font = UIFont(name: "Lato-Regular", size: 16)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Constant.appDelegate.isCallingVideoViewOpen = false
        self.player?.pause()
        self.navigationController?.setNavigationBarHidden(true, animated:true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "myCall"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "cancelCall"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "cancelCallQuitMode"), object: nil)
    }
    
    // MARK: - Custom Functions
    func setView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        bottomView.layer.cornerRadius = 30
        bottomView.clipsToBounds = true
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        Constant.appDelegate.isCallingVideoViewOpen = true
        self.titleLbl.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Calling..."
        self.navigationItem.setHidesBackButton(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(connectMyCall), name: NSNotification.Name(rawValue: "myCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelCall), name: NSNotification.Name(rawValue: "cancelCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelCallonQuitMode), name: NSNotification.Name(rawValue: "cancelCallQuitMode"), object: nil)
        collectionView.register(UINib(nibName: "RemoteVideoCVC", bundle: nil), forCellWithReuseIdentifier: "RemoteVideoCVC")
        
        cameraType = "front"
        self.disconnectBtn.isHidden = true
        self.micButton.isHidden = false
        if(self.bookingId != "") {
            self.playSound()
            self.previewView.frame = CGRect(x: self.view.frame.origin.x, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 330)
            self.startPreview()
            self.createRoom()
            self.view.bringSubviewToFront(previewView)
            
            newTimerValue = 15
            ringerTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playTimerChecker), userInfo: nil, repeats: true)
        } else {
            self.previewView.frame = CGRect(x: self.view.frame.origin.x, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 330)
            self.navigationItem.title = "Connecting..."
            self.anotheuserConnectCall()
        }
        
        if(self.timer != nil) {
            timer.invalidate()
        }
        if(self.ringerTime != nil) {
        }
    }
    
    func autoConnectTriggered() {
        self.navigationController?.dismiss(animated: true) {
            self.checkCallStatus(onCall: false)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func runTimer() {
        callStartTime = Date()
        if timer != nil {
            return  // Prevent restarting timer if already running
        }
        timerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCallDuration), userInfo: nil, repeats: true)
    }
    
    @objc func updateCallDuration() {
        guard let start = callStartTime else { return }
        var elapsedTime = 0
        if let startTime = callStartTime {
            elapsedTime = Int(Date().timeIntervalSince(startTime))
        }
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        callDuration.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func playSound() {
        let path = Bundle.main.path(forResource: "old_phone.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.currentTime = 0
            player?.volume = 3.0
            player?.numberOfLoops = 10
            player?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    @objc func playTimerChecker() {
        newTimerValue = newTimerValue - 1
        if(newTimerValue == 0) {
            if(!bothConnected) {
                self.player?.pause()
                if(timer != nil) {
                    timer.invalidate()
                }
                if let room = room {
                    logMessage(messageText: "Attempting to disconnect from room \(room.name)")
                }
                userInitiatedDisconnect = true
                if let room = room {
                    room.disconnect()
                }
                if(self.bookingId != "") {
                    print("cancel call 1")
                    Constant.appDelegate.currentVideoCallID =  ""
                    self.cancelCallFinal(isCancel: "no", bookingId: self.bookingId, email: "test@gmail.com", timeLeft: timerValue)
                } else {
                    let bookingID =  self.anohterUserDict["bookingId"] as! String
                    print("cancel call 2")
                    Constant.appDelegate.currentVideoCallID =  ""
                    self.cancelCallFinal(isCancel: "no", bookingId: bookingID, email: "test@gmail.com", timeLeft: timerValue)
                }
            }
        }
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
                Constant.appDelegate.currentVideoCallID = ""
                self.cancelCallFinal(isCancel: "no", bookingId: bookingID, email: "test@gmail.com", timeLeft: timerValue)
            }
        }
    }
    
    @objc private func cancelCall(notification: NSNotification) {
        if(self.navigationController != nil) {
            if((self.timer) != nil) {
                timer.invalidate()
            }
            if(self.ringerTime != nil) {
                self.ringerTime.invalidate()
            }
            let user = Storage.shared.readUser()
            let userLoginType = user?.userLoginType ?? ""
            if userLoginType == "Admin" {
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
        self.remoteParticipants = []
        
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
                self.remoteParticipants = []
                
                let user = Storage.shared.readUser()
                let userLoginType = user?.userLoginType ?? ""
                if userLoginType == "Admin" {
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
    
    func isAlreadyOnCall() {
        Socketton.shared.isOnAnotherCall = { json in
            print(json)
            print("Another Call Json = \(json)")
            if self.viewIfLoaded?.window != nil {
                let chat = ChatData(json)
                if chat.senderId == self.cID {
                    if (self.ringerTime != nil) {
                        self.ringerTime.invalidate()
                        self.timerValue = 0
                    }
                    let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "alert", ofType: "mp3")!)
                    do {
                        if (self.player != nil) {
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
    
    func flipCamera() {
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
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.room != nil
    }
    
    func updateNavigationTitle() {
        let users = userListData.filter { user in
            return self.remoteParticipants.contains { $0.identity == user.userId }
        }
        var fullNames: String
        
        if users.count == 1 {
            fullNames = celeName
        } else if users.count > 2 {
            fullNames = users.prefix(2).map { $0.fullName ?? "" }.joined(separator: ", ") + " and \(users.count - 2) others"
        } else {
            fullNames = users.map { $0.fullName ?? "" }.joined(separator: ", ")
        }
        self.navigationItem.title = fullNames
    }
    
    func setupRemoteVideoView() {
        self.titleLbl.isHidden = true
        self.previewView.frame = CGRect(x: self.view.frame.size.width - 130, y: 100, width: 125, height: 160)
        
        if !self.bookingId.isEmpty {
            self.player?.pause()
            self.player = nil
            self.ringerTime.invalidate()
        }
        if !timerRunning {
            self.runTimer()
        }
        Constant.appDelegate.hideProgressHUD()
    }
    
    func startPreview() {
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)
        
        print("Coming connect call start preview")
        
        if (frontCamera != nil || backCamera != nil) {
            print("coming connect call start preview camera not nil")
            
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
            print("Coming Connect Call start preview camera not nil add preview")
            
            camera!.startCapture(device: frontCamera != nil ? frontCamera!: backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    print("Coming Connect Call start preview camera not nil error")
                    self.startPreview()
                } else {
                    self.previewView.shouldMirror = (captureDevice.position == .front)
                    print("Coming Connect Call start preview camera not nil fronwt")
                }
            }
        } else {
            self.flipCamera()
            self.logMessage(messageText: "No front or back capture device found!")
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
        self.disconnectBtn.isHidden = !inRoom
        
        if (self.anohterUserDict != nil) {
            Constant.appDelegate.currentVideoCallID = self.anohterUserDict["receiverId"] as! String
        }
        UIApplication.shared.isIdleTimerDisabled = inRoom
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    func cleanupRemoteParticipant() {
        self.remoteParticipants = []
    }
    
    func holdCall(onHold: Bool) {
        localAudioTrack?.isEnabled = !onHold
        localVideoTrack?.isEnabled = !onHold
    }
    
    func logMessage(messageText: String) {
        NSLog(messageText)
        self.titleLbl.isHidden = true
        if(titleLbl != nil) {
        }
    }
    
    func exitCall() {
        var param: [String: Any] = [:]
        param.updateValue(roomSid, forKey: "roomSid")
        self.view.endEditing(true)
        if(self.remoteParticipants.count == 0) {
            param.updateValue(self.otherUserId, forKey: "otherUserId")
        }
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().exitCall(params: param) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                print("success")
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    
    func checkCallStatus(onCall: Bool) {
        let param = ["isOnCall": onCall, "otherUserId": UserDefaults.loggedInUserId] as [String: Any]
        LoggedInRequest().updateCallStatus(params: param) { response, error in
            if error != nil {
                print(response ?? "")
            } else {
                print(error?.message ?? "")
            }
        }
    }
    
    private func setupAudioSession() {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
                try audioSession.setActive(true)
            } catch {
                print("Error setting up audio session: \(error.localizedDescription)")
            }
        }
    
    private func toggleSpeaker(_ sender: UIButton) {
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                if isSpeakerEnabled {
                    // Turn speaker OFF (use default audio output)
                    try audioSession.overrideOutputAudioPort(.none)
                    sender.setImage(UIImage(named: "speakerOff"), for: .normal)
                    print("Speaker Off")
                } else {
                    // Turn speaker ON
                    try audioSession.overrideOutputAudioPort(.speaker)
                    sender.setImage(UIImage(named: "speakerOn"), for: .normal)
                    print("Speaker On")
                }
                isSpeakerEnabled.toggle()
            } catch {
                print("Error toggling speaker: \(error.localizedDescription)")
            }
        }
    
//    @objc private func callDeinitialise(_ notification: Notification) {
//        checkCallStatus(onCall: false)
//    }
    
    @objc private func audioRouteChanged(_ notification: Notification) {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute

        if isBluetoothConnected() {
            print("Bluetooth Connected")
            speakerBtn.setImage(UIImage(named: "bluetooth"), for: .normal)
        } else if isWiredHeadsetConnected() {
            print("Wired Headset Connected")
            speakerBtn.setImage(UIImage(named: "wiredEarphone"), for: .normal)
        } else {
            print("Defaulting to Speaker")
            speakerBtn.setImage(UIImage(named: "speakerOn"), for: .normal)
        }
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func isBluetoothConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.currentRoute.outputs.contains {
            $0.portType == .bluetoothA2DP ||
            $0.portType == .bluetoothHFP ||
            $0.portType == .bluetoothLE
        }
    }
    
    private func isWiredHeadsetConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.currentRoute.outputs.contains { $0.portType == .headphones }
    }
    
    /// Handle Audio Output Switching
    private func switchAudioOutput(to output: AudioOutputType) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            switch output {
            case .speaker:
                try audioSession.overrideOutputAudioPort(.speaker)
                speakerBtn.setImage(UIImage(named: "speakerOn"), for: .normal)
                isSpeakerEnabled = true
                print("Switched to Speaker")
                
            case .bluetooth:
                try audioSession.overrideOutputAudioPort(.none) // Let system use Bluetooth
                speakerBtn.setImage(UIImage(named: "bluetooth"), for: .normal)
                isSpeakerEnabled = false
                print("Switched to Bluetooth")
                
            case .headphones:
                try audioSession.overrideOutputAudioPort(.none) // Let system use wired headset
                speakerBtn.setImage(UIImage(named: "wiredEarphone"), for: .normal)
                isSpeakerEnabled = false
                print("Switched to Wired Headset")
                
            default:
                        break
            }
            updateAudioRoute()
        } catch {
            print("Error switching audio output: \(error.localizedDescription)")
        }
    }
    
    private func updateAudioRoute() {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute.outputs

        isMobileBluetoothConnected = currentRoute.contains {
            $0.portType == .bluetoothA2DP || $0.portType == .bluetoothLE || $0.portType == .bluetoothHFP
        }
        
        isMobileWiredHeadsetConnected = currentRoute.contains { $0.portType == .headphones }
    }
    
    private func showAudioSelectionSheet() {
        let alert = UIAlertController(title: "Select Audio Output", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Speaker", style: .default, handler: { _ in
               self.switchAudioOutput(to: .speaker)
           }))
        
        if isBluetoothConnected() {
            alert.addAction(UIAlertAction(title: "Bluetooth", style: .default, handler: { _ in
                self.switchAudioOutput(to: .bluetooth)
            }))
        }
        
        if isWiredHeadsetConnected() {
            alert.addAction(UIAlertAction(title: "Wired Headset", style: .default, handler: { _ in
                self.switchAudioOutput(to: .headphones)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let topVC = UIApplication.shared.keyWindow?.rootViewController {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    
    private func toggleSpeaker() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            if isSpeakerEnabled {
                try audioSession.overrideOutputAudioPort(.none)
                speakerBtn.setImage(UIImage(named: "speakerOff"), for: .normal)
                print("Speaker Off")
            } else {
                try audioSession.overrideOutputAudioPort(.speaker)
                speakerBtn.setImage(UIImage(named: "speakerOn"), for: .normal)
                print("Speaker On")
            }
            isSpeakerEnabled.toggle()
        } catch {
            print("Error toggling speaker: \(error.localizedDescription)")
        }
    }
    
    // MARK: - IBActions
    @IBAction func disconnectCall(_ sender: UIButton) {
        if let room = room {
            logMessage(messageText: "Attempting to disconnect from room \(room.name)")
            userInitiatedDisconnect = true
            self.navigationController?.dismiss(animated: true)
            exitCall()
        }
    }
    
    @IBAction func muteUnmuteCall(_ sender: UIButton) {
        if let _ = room, let localAudioTrack = self.localAudioTrack {
            let isMuted = localAudioTrack.isEnabled
            localAudioTrack.isEnabled = !isMuted
            if (!isMuted) {
                self.micButton.setImage(UIImage(named: "muteOn"), for: .normal)
            } else {
                self.micButton.setImage(UIImage(named: "muteOff"), for: .normal)
            }
        }
    }
    
    @IBAction func speakerBtn(_ sender: UIButton) {
        updateAudioRoute()

        if isBluetoothConnected() || isWiredHeadsetConnected() {
            showAudioSelectionSheet()
        } else {
            toggleSpeaker()
        }
    }
    
    @IBAction func videoCallBtn(_ sender: UIButton) {
        self.flipCamera()
    }
    
    @IBAction func menuBtnAction(_ sender: UIButton) {
        let vc = RegisteredUserVC()
        vc.roomSid = roomSid
        vc.roomName = roomName
        vc.comingFrom = true
        vc.heading = "In call"
        vc.allUsers = userListData
        vc.remoteParticipants = remoteParticipants
        vc.modalPresentationStyle = .pageSheet
        vc.modalTransitionStyle = .coverVertical
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
        } else {
            // Fallback on earlier versions
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func addOtherUserCallBtnAction(_ sender: UIButton) {
        let vc = RegisteredUserVC()
        vc.roomSid = roomSid
        vc.roomName = roomName
        vc.heading = "Add People"
        vc.allUsers = userListData
        vc.modalPresentationStyle = .pageSheet
        vc.modalTransitionStyle = .coverVertical
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
        } else {
            // Fallback on earlier versions
        }
        self.present(vc, animated: true)
    }
    
    func getRemoteParticipantById(_ userId: String) -> RemoteParticipant? {
        return remoteParticipants.first { $0.identity == userId }
    }
}

    // MARK: - Extensions
extension VideoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func getCount() -> Int {
        let usersCount = remoteParticipants.count
        if usersCount != 1 && usersCount % 2 == 1 {
            return usersCount + 1
        } else {
            return usersCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemoteVideoCVC", for: indexPath) as! RemoteVideoCVC
        cell.videoView!.contentMode = .scaleAspectFill
        if remoteParticipants.count == 0 || indexPath.item == remoteParticipants.count {
            if let cameraSource = localVideoTrack?.source as? CameraSource {
                cell.videoView.shouldMirror = cameraSource.device?.position == .front
            }
            cell.videoView.transform = CGAffineTransform(scaleX: -1, y: 1) // Flips horizontally
            cell.isLocal = true
            cell.localRenderer = localVideoTrack
            localVideoTrack?.addRenderer(cell.videoView!)
        } else {
            let participant = remoteParticipants[indexPath.item]
            let videoPublications = participant.remoteVideoTracks
            
            for publication in videoPublications {
                if let subscribedVideoTrack = publication.remoteTrack,
                   publication.isTrackSubscribed {
                    subscribedVideoTrack.removeRenderer(cell.videoView!)
                    cell.isLocal = false
                    cell.remoteRenderer = subscribedVideoTrack
                    subscribedVideoTrack.addRenderer(cell.videoView!)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = getCount()
        switch count {
        case 1:
            return collectionView.size
        case 2:
            return CGSize(width: collectionView.width, height: collectionView.height / 2)
        case 4:
            return CGSize(width: collectionView.width / 2, height: collectionView.height / 2)
        case 6:
            return CGSize(width: collectionView.width / 2, height: collectionView.height / 3)
        case 8:
            return CGSize(width: collectionView.width / 2, height: collectionView.height / 4)
        case 10:
            return CGSize(width: collectionView.width / 2, height: collectionView.height / 5)
        default:
            return collectionView.size
        }
    }
}

// MARK: - RoomDelegate
extension VideoVC : RoomDelegate {
    func roomDidConnect(room: Room) {
        logMessage(messageText: "Connected" )
        checkCallStatus(onCall: true)
        for remoteParticipant in room.remoteParticipants {
            remoteParticipant.delegate = self
        }
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        logMessage(messageText: "Disconnected")
        print("Coming..... room disconnect")
        self.cleanupRemoteParticipant()
        self.room = nil
//        checkCallStatus(onCall: false)
        self.showRoomUI(inRoom: false)
        self.callKitCompletionHandler = nil
        self.camera = nil
        self.localAudioTrack = nil
        self.localVideoTrack = nil
        self.remoteParticipants = []
        
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
extension VideoVC : RemoteParticipantDelegate {
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
        remoteParticipants.append(participant)
        setupRemoteVideoView()
    }
    
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")
        
        let index = remoteParticipants.firstIndex(where: { $0.identity == participant.identity })
        if let index = index {
            remoteParticipants.remove(at: index)
            
        }
        if remoteParticipants.count == 0 {
            autoConnectTriggered()
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
extension VideoVC : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK: - CameraSourceDelegate
extension VideoVC : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        logMessage(messageText: "Camera source failed with error: \(error.localizedDescription)")
    }
}
//
//extension UIApplication {
//    class var statusBarBackgroundColor: UIColor? {
//        get {
//            return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
//        } set {
//            (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
//        }
//    }
//}

extension VideoVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if (self.isViaAlert) {
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

extension VideoVC {
    func getContactList() {
        var requestDict1 = [String: Any]()
        var arrDict1 = [Any]()
        for contact in contacts {
            if let mobile = contact.mobile, mobile != "" {
                let mobileDict1: [String: Any] = ["mobile": mobile]
                arrDict1.append(mobileDict1)
            }
        }
        requestDict1 = ["mobileList": arrDict1]
        checkRegisteredMobileRequest(requestParams: requestDict1)
    }
    
    func checkRegisteredMobileRequest(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().checkRegisteredMobileRequest(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else {return}
                do {
                    let responseData = try JSONDecoder().decode(CheckContactsModel.self, from: data)
                    self.userListData = responseData.data.mobileList.filter({ $0.userId != "" })
                } catch let err {
                    print("Error = \(err)")
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}

 enum AudioOutputType {
    case speaker
    case bluetooth
    case headphones
}
