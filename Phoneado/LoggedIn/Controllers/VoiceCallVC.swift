//
//  VoiceCallVC.swift
//  Famz
//
//  Created by Deviser on 6/14/22.
//  Copyright © 2022 Zimble. All rights reserved.
//

import UIKit
import AVFoundation
import PushKit
import CallKit
import TwilioVoice


class VoiceCallVC: UIViewController {
        
    @IBOutlet var userImg: UIImageView!
    @IBOutlet var callingLbl: UILabel!
    var userMobile:String = String()
    var roomName:String = String()
    var bookingId:String = String()
    var celeName:String = String()
    var celeImg:String = String()

    var cID:String = String()
    var timerValue:Int = Int()
    
    @IBOutlet var speakBtn: UIButton!
    @IBOutlet var muteBtn: UIButton!
    let twimlParamTo = "to"
    let kRegistrationTTLInDays = 365
    let kCachedDeviceToken = "CachedDeviceToken"
    let kCachedBindingDate = "CachedBindingDate"
    
    var incomingPushCompletionCallback: (() -> Void)?
    var isSpinning: Bool
    var incomingAlertController: UIAlertController?

    var callKitCompletionCallback: ((Bool) -> Void)? = nil
    var audioDevice = DefaultAudioDevice()
    var activeCallInvites: [String: CallInvite]! = [:]
    var activeCalls: [String: Call]! = [:]
    
    // activeCall represents the last connected call
    var activeCall: Call? = nil

    var callKitProvider: CXProvider?
    let callKitCallController = CXCallController()
    var userInitiatedDisconnect: Bool = false
    var playCustomRingback = false
    var ringtonePlayer: AVAudioPlayer? = nil
    var isViaNotification:Bool = Bool()
    var notificationDict:NSDictionary!
    
    var voiceCallVC:VoiceCallVC!
    var ringerTime:Timer!
    var celbUUID:String = String()
    var isMute:Bool = Bool()
    var isSpeak:Bool = Bool()
    
    var userImgaePic:String = String()
    var isViaAlert:Bool = Bool()

    
    required init?(coder aDecoder: NSCoder) {
        isSpinning = false
        super.init(coder: aDecoder)
    }
    
    deinit {
        // CallKit has an odd API contract where the developer must call invalidate or the CXProvider is leaked.
        if let provider = callKitProvider {
            provider.invalidate()
        }
    }
    
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
//                    let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "alert", ofType: "mp3")!)
                    
/*                    do {
                        
//                        if (self.ringtonePlayer != nil){
//                            self.ringtonePlayer?.stop()
//                        }
//
//                        self.ringtonePlayer = try AVAudioPlayer(contentsOf: ringtonePath)
//                        self.ringtonePlayer?.delegate = self
//                        self.ringtonePlayer?.numberOfLoops = -1
//                        self.ringtonePlayer?.volume = 1.0
//                        self.ringtonePlayer?.play()
//                        self.isViaAlert = true
                    } catch {
                    }*/

                }
            }
        }
    }
    
    func initaiteVoiceCall(dict:[String:String]){
        Socketton.shared.establishConnection()
        self.isAlreadyOnCall()
        self.isMessageReceived()

        //TwilioVoiceSDK.audioDevice = audioDevice
        
        if (Constant.appDelegate.isCallingViewOpen || Constant.appDelegate.isCallingVideoViewOpen){
                        
            let sendMessageData = ["type":"isOnAntoherCall","senderId":Storage.shared.readUser()?.userId ?? "","receiverId":dict["toId"]!,"status":"connected"]
            Socketton.shared.alreadyAnotherCall(json: sendMessageData )

            
        }else{
            self.celeName = dict["data"]!
            self.cID = dict["toId"]!
            let configuration = CXProviderConfiguration(localizedName:dict["data"]!)
            self.timerValue = 0
           // self.userImgaePic = dict["pic"]!
            
            configuration.maximumCallGroups = 1
            configuration.maximumCallsPerCallGroup = 1
            callKitProvider = CXProvider(configuration: configuration)
            if let provider = callKitProvider {
                provider.setDelegate(self, queue: nil)
            }

        }
        

    }
    
    func isMessageReceived() {
        Socketton.shared.isConnected = { json in
            print(json)
            print("Message Json = \(json)")
            if self.viewIfLoaded?.window != nil {
               let chat = ChatData(json)
                if chat.senderId == self.cID{
                    if (self.ringerTime != nil){
                        self.ringerTime.invalidate()
                        self.timerValue = 0
                    }
                    
                    if (self.cID != ""){
                        let param = ["isOnCall":true,"otherUserId":self.cID] as [String : Any]
                        LoggedInRequest().updateCallStatus(params: param) { response, error in
                            print(response)
                        }
                    }else{
                        let param = ["isOnCall":true,"otherUserId":self.bookingId] as [String : Any]
                        LoggedInRequest().updateCallStatus(params: param) { response, error in
                            print(response)
                        }

                    }
                    
                    
                    self.ringerTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.playTimer), userInfo: nil, repeats: true)

                }
            }
        }
    }

    
    @IBAction func speakButtonClicked(_ sender: UIButton) {
        
        if (!isSpeak){
            isSpeak = true
            speakBtn.setImage(UIImage(named: "speaker"), for: .normal)
        }else{
            isSpeak = false
            speakBtn.setImage(UIImage(named: "mute_speaker"), for: .normal)

        }
        
        self.toggleAudioRoute(toSpeaker: isSpeak)
    }
    @IBAction func muteBtnClicked(_ sender: UIButton) {
        
        if (!isMute){
            isMute = true
            muteBtn.setImage(UIImage(named: "mute_microphone"), for: .normal)

        }else{
            isMute = false
            muteBtn.setImage(UIImage(named: "Microphone"), for: .normal)

        }

        guard let activeCall = activeCall else { return }
        activeCall.isMuted = self.isMute


        
    }
    
    @objc func playTimer(){
        timerValue = timerValue + 1
        let seconds = (timerValue) % 60
        let minutes = ((timerValue) / 60) % 60
        let hour = timerValue / 3600
        
        if(hour > 0){
            
            let time = String(format: "%0.2d:%0.2d:%0.2d",hour,minutes,seconds)
            if (callingLbl != nil){
                self.callingLbl.text = time
            }
            
            }else{
            let time = String(format: "%0.2d:%0.2d",minutes,seconds)
                if (callingLbl != nil){
                    self.callingLbl.text = time
                }

        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        Constant.appDelegate.isCallingViewOpen = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isMessageReceived()
        self.isAlreadyOnCall()
        Constant.appDelegate.isCallingViewOpen = true
        
        guard activeCall == nil else {
           // userInitiatedDisconnect = true
            //toggleUIState(isEnabled: false, showCallControl: false)
            return
        }
        
        if (isViaNotification){
            
            if (self.userImg != nil){
                self.userImg.sd_setImage(with: URL(string:self.userImgaePic ), completed: nil)
            }

            
        }else{
            
            isSpeak = true
            isMute = false
          //  self.toggleAudioRoute(toSpeaker: isSpeak)
           // guard let activeCall = activeCall else { return }
            //activeCall.isMuted = self.isMute
            self.userImg.sd_setImage(with: URL(string: celeImg), completed: nil)
            self.callingLbl.text = "Calling to \(celeName)"
            self.callingLbl.textColor = UIColor.black
               
            
                //TwilioVoiceSDK.audioDevice = audioDevice
                let configuration = CXProviderConfiguration(localizedName: "Phoneado")
                configuration.maximumCallGroups = 1
                configuration.maximumCallsPerCallGroup = 1
                callKitProvider = CXProvider(configuration: configuration)
                if let provider = callKitProvider {
                    provider.setDelegate(self, queue: nil)
                }
                
                checkRecordPermission { [weak self] permissionGranted in
                    let uuid = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
                    let handle = "Voice Bot"
                    guard !permissionGranted else {
                        self?.performStartCallAction(uuid: uuid, handle: handle)
                        return
                    }

            }

            
        }

    }
    
    func toggleAudioRoute(toSpeaker: Bool) {
        // The mode set by the Voice SDK is "VoiceChat" so the default audio route is the built-in receiver. Use port override to switch the route.
        audioDevice.block = {
            DefaultAudioDevice.DefaultAVAudioSessionConfigurationBlock()
            
            do {
                if toSpeaker {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                } else {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                }
            } catch {
                NSLog(error.localizedDescription)
            }
        }
        
        audioDevice.block()
    }

    
    func checkRecordPermission(completion: @escaping (_ permissionGranted: Bool) -> Void) {
        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
        
        switch permissionStatus {
        case .granted:
            // Record permission already granted.
            completion(true)
        case .denied:
            // Record permission denied.
            completion(false)
        case .undetermined:
            // Requesting record permission.
            // Optional: pop up app dialog to let the users know if they want to request.
            AVAudioSession.sharedInstance().requestRecordPermission { granted in completion(granted) }
        default:
            completion(false)
        }
    }

    
    func endCall(){
        
        if (isViaNotification){
            
            performEndCallAction(uuid: UUID(uuidString:self.celbUUID)!)
            
            if let invite = activeCallInvites[self.celbUUID] {
                invite.reject()
                activeCallInvites.removeValue(forKey:self.celbUUID)
            } else if let call = activeCalls[self.celbUUID] {
                call.disconnect()
            } else {
                NSLog("Unknown UUID to perform end-call action with")
            }

            
        }else{
            
            performEndCallAction(uuid: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!)
            
            if let invite = activeCallInvites["E621E1F8-C36C-495A-93FC-0C247A3E6E5F"] {
                invite.reject()
                activeCallInvites.removeValue(forKey:"E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
            } else if let call = activeCalls["E621E1F8-C36C-495A-93FC-0C247A3E6E5F"] {
                call.disconnect()
            }else if activeCall?.uuid != nil {
                let call = activeCalls["\(activeCall!.uuid!)"]
                call!.disconnect()
            }
            
            else {
                NSLog("Unknown UUID to perform end-call action with")
            }
        }
        
        let user = Storage.shared.readUser()
        let userLoginType = user?.userLoginType ?? ""
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "enable"), object:nil,userInfo:nil)
        
        if (self.cID != ""){
            let param = ["isOnCall":false,"otherUserId":self.cID] as [String : Any]
            LoggedInRequest().updateCallStatus(params: param) { response, error in
                print(response)
            }
        }else{
            let param = ["isOnCall":false,"otherUserId":self.bookingId] as [String : Any]
            LoggedInRequest().updateCallStatus(params: param) { response, error in
                print(response)
            }

        }

        if userLoginType == "Admin" {
            
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


            
           // self.navigationController?.popViewController(animated: true)
            
        }else{
            Storage().clearAllCachedData()
            LocationManager.shared.stopUpdatingLocation()
            Constant.sceneDelegate?.ShowRootViewController()
        }


    }
    
    @IBAction func endButtonClicked(_ sender: UIButton) {
        self.endCall()
    }
    
}
extension VoiceCallVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
            if (self.isViaAlert){
                self.endCall()
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


// MARK: - TVONotificaitonDelegate

extension VoiceCallVC: NotificationDelegate {
    func callInviteReceived(callInvite: CallInvite) {
        NSLog("callInviteReceived:")
        
        /**
         * The TTL of a registration is 1 year. The TTL for registration for this device/identity
         * pair is reset to 1 year whenever a new registration occurs or a push notification is
         * sent to this device/identity pair.
         */
        UserDefaults.standard.set(Date(), forKey: kCachedBindingDate)
        
        let callerInfo: TVOCallerInfo = callInvite.callerInfo
        if let verified: NSNumber = callerInfo.verified {
            if verified.boolValue {
                NSLog("Call invite received from verified caller number!")
            }
        }
        
        let from = (callInvite.from ?? "Voice Bot").replacingOccurrences(of: "client:", with: "")

        // Always report to CallKit
        reportIncomingCall(from: from, uuid: callInvite.uuid)
        activeCallInvites[callInvite.uuid.uuidString] = callInvite
    }
    
    func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
        NSLog("cancelledCallInviteCanceled:error:, error: \(error.localizedDescription)")

        guard let activeCallInvites = activeCallInvites, !activeCallInvites.isEmpty else {
            NSLog("No pending call invite")
            return
        }
        
        let callInvite = activeCallInvites.values.first { invite in invite.callSid == cancelledCallInvite.callSid }
        
        if let callInvite = callInvite {
            performEndCallAction(uuid: callInvite.uuid)
            self.activeCallInvites.removeValue(forKey: callInvite.uuid.uuidString)
        }
    }
}

// MARK: - TVOCallDelegate

extension VoiceCallVC: CallDelegate {
    func callDidStartRinging(call: Call) {
        NSLog("callDidStartRinging:")
        if (self.callingLbl != nil){
            self.callingLbl.text = "Ringing"
        }
        self.toggleAudioRoute(toSpeaker: false)

        if playCustomRingback {
            playRingback()
        }
    }
    
    func callDidConnect(call: Call) {
        NSLog("callDidConnect:")
        
        if playCustomRingback {
            stopRingback()
        }
        
        if let callKitCompletionCallback = callKitCompletionCallback {
            callKitCompletionCallback(true)
            
        }
    }
    
    func call(call: Call, isReconnectingWithError error: Error) {
        NSLog("call:isReconnectingWithError:")
        
//        placeCallButton.setTitle("Reconnecting", for: .normal)
//
//        toggleUIState(isEnabled: false, showCallControl: false)
    }
    
    func callDidReconnect(call: Call) {
        NSLog("callDidReconnect:")
        
//        placeCallButton.setTitle("Hang Up", for: .normal)
//
//        toggleUIState(isEnabled: true, showCallControl: true)
    }
    
    func callDidFailToConnect(call: Call, error: Error) {
        NSLog("Call failed to connect: \(error.localizedDescription)")
        
        if let completion = callKitCompletionCallback {
            completion(false)
        }
        
        if let provider = callKitProvider {
            provider.reportCall(with: call.uuid!, endedAt: Date(), reason: CXCallEndedReason.failed)
        }

        callDisconnected(call: call)
    }
    
    func callDidDisconnect(call: Call, error: Error?) {
        if let error = error {
            NSLog("Call failed: \(error.localizedDescription)")
        } else {
            NSLog("Call disconnected")
        }
        
        if !userInitiatedDisconnect {
            var reason = CXCallEndedReason.remoteEnded
            
            if error != nil {
                reason = .failed
            }
            
            if let provider = callKitProvider {
                provider.reportCall(with: call.uuid!, endedAt: Date(), reason: reason)
            }
        }

        callDisconnected(call: call)
    }
    
    func callDisconnected(call: Call) {
        if call == activeCall {
            activeCall = nil
        }
        
        activeCalls.removeValue(forKey: call.uuid!.uuidString)
        
        userInitiatedDisconnect = false
        
        if playCustomRingback {
            stopRingback()
        }
        if (self.ringerTime != nil){
            self.ringerTime.invalidate()
            self.timerValue = 0
        }

        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "enable"), object:nil,userInfo:nil)

        let user = Storage.shared.readUser()
        let userLoginType = user?.userLoginType ?? ""
        
        if (self.cID != ""){
            let param = ["isOnCall":false,"otherUserId":self.cID] as [String : Any]
            LoggedInRequest().updateCallStatus(params: param) { response, error in
                print(response)
            }
        }else{
            let param = ["isOnCall":false,"otherUserId":self.bookingId] as [String : Any]
            LoggedInRequest().updateCallStatus(params: param) { response, error in
                print(response)
            }

        }


        
        if userLoginType == "Admin" {
            
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


            //self.navigationController?.popViewController(animated: true)
            
        }else{
            Storage().clearAllCachedData()
            LocationManager.shared.stopUpdatingLocation()
            Constant.sceneDelegate?.ShowRootViewController()
        }

        

    }
    
    func callDidReceiveQualityWarnings(call: Call, currentWarnings: Set<NSNumber>, previousWarnings: Set<NSNumber>) {
        /**
        * currentWarnings: existing quality warnings that have not been cleared yet
        * previousWarnings: last set of warnings prior to receiving this callback
        *
        * Example:
        *   - currentWarnings: { A, B }
        *   - previousWarnings: { B, C }
        *   - intersection: { B }
        *
        * Newly raised warnings = currentWarnings - intersection = { A }
        * Newly cleared warnings = previousWarnings - intersection = { C }
        */
        var warningsIntersection: Set<NSNumber> = currentWarnings
        warningsIntersection = warningsIntersection.intersection(previousWarnings)
        
        var newWarnings: Set<NSNumber> = currentWarnings
        newWarnings.subtract(warningsIntersection)
        if newWarnings.count > 0 {
            qualityWarningsUpdatePopup(newWarnings, isCleared: false)
        }
        
        var clearedWarnings: Set<NSNumber> = previousWarnings
        clearedWarnings.subtract(warningsIntersection)
        if clearedWarnings.count > 0 {
            qualityWarningsUpdatePopup(clearedWarnings, isCleared: true)
        }
    }
    
    func qualityWarningsUpdatePopup(_ warnings: Set<NSNumber>, isCleared: Bool) {
        var popupMessage: String = "Warnings detected: "
        if isCleared {
            popupMessage = "Warnings cleared: "
        }
        
        let mappedWarnings: [String] = warnings.map { number in warningString(Call.QualityWarning(rawValue: number.uintValue)!)}
        popupMessage += mappedWarnings.joined(separator: ", ")
        
        print(popupMessage)
        
     /*   qualityWarningsToaster.alpha = 0.0
        qualityWarningsToaster.text = popupMessage
        UIView.animate(withDuration: 1.0, animations: {
            self.qualityWarningsToaster.isHidden = false
            self.qualityWarningsToaster.alpha = 1.0
        }) { [weak self] finish in
            guard let strongSelf = self else { return }
            let deadlineTime = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                UIView.animate(withDuration: 1.0, animations: {
                    strongSelf.qualityWarningsToaster.alpha = 0.0
                }) { (finished) in
                    strongSelf.qualityWarningsToaster.isHidden = true
                }
            })
        } */
    }
    
    func warningString(_ warning: Call.QualityWarning) -> String {
        switch warning {
        case .highRtt: return "high-rtt"
        case .highJitter: return "high-jitter"
        case .highPacketsLostFraction: return "high-packets-lost-fraction"
        case .lowMos: return "low-mos"
        case .constantAudioInputLevel:
            
//            if (self.ringerTime != nil){
//                self.ringerTime.invalidate()
//            }
//
//            self.endCall()
            return "constant-audio-input-level"
            default: return "Unknown warning"
        }
    }
    
    
    // MARK: Ringtone
    
    func playRingback() {
        let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "ringtone", ofType: "wav")!)
        
        do {
            ringtonePlayer = try AVAudioPlayer(contentsOf: ringtonePath)
            ringtonePlayer?.delegate = self
            ringtonePlayer?.numberOfLoops = -1
            
            ringtonePlayer?.volume = 1.0
            ringtonePlayer?.play()
        } catch {
            NSLog("Failed to initialize audio player")
        }
    }
    
    func stopRingback() {
        guard let ringtonePlayer = ringtonePlayer, ringtonePlayer.isPlaying else { return }
        
        ringtonePlayer.stop()
    }
}


// MARK: - CXProviderDelegate

extension VoiceCallVC: CXProviderDelegate {
   func providerDidReset(_ provider: CXProvider) {
       NSLog("providerDidReset:")
       audioDevice.isEnabled = false
   }

   func providerDidBegin(_ provider: CXProvider) {
       NSLog("providerDidBegin")
   }

   func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
       NSLog("provider:didActivateAudioSession:")
       audioDevice.isEnabled = true
   }

   func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
       NSLog("provider:didDeactivateAudioSession:")
       audioDevice.isEnabled = false
   }

   func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
       NSLog("provider:timedOutPerformingAction:")
       NotificationCenter.default.post(name:NSNotification.Name(rawValue: "enable"), object:nil,userInfo:nil)
       Constant.appDelegate.isButtonEnable = true
   }

   func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
       NSLog("provider:performStartCallAction:")
       
//       toggleUIState(isEnabled: false, showCallControl: false)
//       startSpin()
       
       provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
       
       performVoiceCall(uuid: action.callUUID, client: "") { success in
           if success {
               NSLog("performVoiceCall() successful")
               provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
           } else {
               NSLog("performVoiceCall() failed")
           }
       }
       
       action.fulfill()
   }

   func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
       NSLog("provider:performAnswerCallAction:")
       
       Constant.appDelegate.pushView()
       
       performAnswerVoiceCall(uuid: action.callUUID) { success in
           if success {
               NSLog("performAnswerVoiceCall() successful")
           } else {
               NSLog("performAnswerVoiceCall() failed")
           }
       }
       
       action.fulfill()
   }

   func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
       NSLog("provider:performEndCallAction:")
       
       NotificationCenter.default.post(name:NSNotification.Name(rawValue: "enable"), object:nil,userInfo:nil)
       Constant.appDelegate.isButtonEnable = true
       
       let user = Storage.shared.readUser()
       let userLoginType = user?.userLoginType ?? ""

       if (self.cID != ""){
           let param = ["isOnCall":false,"otherUserId":self.cID] as [String : Any]
           LoggedInRequest().updateCallStatus(params: param) { response, error in
               print(response)
           }
       }else{
           let param = ["isOnCall":false,"otherUserId":self.bookingId] as [String : Any]
           LoggedInRequest().updateCallStatus(params: param) { response, error in
               print(response)
           }

       }

       
       if userLoginType == "Admin" {
           //self.navigationController?.popViewController(animated: true)
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

   

           
       }else{
           Storage().clearAllCachedData()
           LocationManager.shared.stopUpdatingLocation()
           Constant.sceneDelegate?.ShowRootViewController()
       }

       
       if let invite = activeCallInvites[action.callUUID.uuidString] {
           invite.reject()
           activeCallInvites.removeValue(forKey: action.callUUID.uuidString)
       } else if let call = activeCalls[action.callUUID.uuidString] {
           call.disconnect()
       } else {
           NSLog("Unknown UUID to perform end-call action with")
       }

       action.fulfill()
   }
   
   func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
       NSLog("provider:performSetHeldAction:")
       
       if let call = activeCalls[action.callUUID.uuidString] {
           call.isOnHold = action.isOnHold
           action.fulfill()
       } else {
           action.fail()
       }
   }
   
   func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
       NSLog("provider:performSetMutedAction:")

       if let call = activeCalls[action.callUUID.uuidString] {
           call.isMuted = action.isMuted
           action.fulfill()
       } else {
           action.fail()
       }
   }

   
   // MARK: Call Kit Actions
   func performStartCallAction(uuid: UUID, handle: String) {
       guard let provider = callKitProvider else {
           NSLog("CallKit provider not available")
           return
       }
       
       let callHandle = CXHandle(type: .generic, value: handle)
       let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
       let transaction = CXTransaction(action: startCallAction)

       callKitCallController.request(transaction) { error in
           if let error = error {
               NSLog("StartCallAction transaction request failed: \(error.localizedDescription)")
               return
           }

           NSLog("StartCallAction transaction request successful")

           let callUpdate = CXCallUpdate()
           callUpdate.localizedCallerName = self.celeName
           callUpdate.remoteHandle = callHandle
           callUpdate.supportsDTMF = true
           callUpdate.supportsHolding = true
           callUpdate.supportsGrouping = false
           callUpdate.supportsUngrouping = false
           callUpdate.hasVideo = false

           provider.reportCall(with: uuid, updated: callUpdate)
       }
   }

   func reportIncomingCall(from: String, uuid: UUID) {
       guard let provider = callKitProvider else {
           NSLog("CallKit provider not available")
           return
       }

       let callHandle = CXHandle(type: .generic, value: from)
       let callUpdate = CXCallUpdate()
       callUpdate.localizedCallerName = self.celeName
       callUpdate.remoteHandle = callHandle
       callUpdate.supportsDTMF = true
       callUpdate.supportsHolding = true
       callUpdate.supportsGrouping = false
       callUpdate.supportsUngrouping = false
       callUpdate.hasVideo = false

       provider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
           if let error = error {
               NSLog("Failed to report incoming call successfully: \(error.localizedDescription).")
           } else {
               NSLog("Incoming call successfully reported.")
           }
       }
   }

   func performEndCallAction(uuid: UUID) {
       
       NotificationCenter.default.post(name:NSNotification.Name(rawValue: "enable"), object:nil,userInfo:nil)
       Constant.appDelegate.isButtonEnable = true

       let endCallAction = CXEndCallAction(call: uuid)
       let transaction = CXTransaction(action: endCallAction)

       callKitCallController.request(transaction) { error in
           if let error = error {
               NSLog("EndCallAction transaction request failed: \(error.localizedDescription).")
           } else {
               NSLog("EndCallAction transaction request successful")
           }
       }
   }
   
   func performVoiceCall(uuid: UUID, client: String?, completionHandler: @escaping (Bool) -> Void) {
       let connectOptions = ConnectOptions(accessToken: Constant.appDelegate.twilioVoiceToken) { builder in
           builder.params = [self.twimlParamTo:self.cID]
           builder.uuid = uuid
       }
       
       let call = TwilioVoiceSDK.connect(options: connectOptions, delegate: self)
       activeCall = call
       activeCalls[call.uuid!.uuidString] = call
       callKitCompletionCallback = completionHandler
   }
   
   func performAnswerVoiceCall(uuid: UUID, completionHandler: @escaping (Bool) -> Void) {
       guard let callInvite = activeCallInvites[uuid.uuidString] else {
           NSLog("No CallInvite matches the UUID")
           return
       }
       
       let acceptOptions = AcceptOptions(callInvite: callInvite) { builder in
           builder.uuid = callInvite.uuid
       }
       
       let call = callInvite.accept(options: acceptOptions, delegate: self)
       activeCall = call
       self.celbUUID = activeCall?.uuid?.uuidString ?? ""
       activeCalls[call.uuid!.uuidString] = call
       callKitCompletionCallback = completionHandler
       
       activeCallInvites.removeValue(forKey: uuid.uuidString)
       
       if (self.ringerTime != nil){
           self.ringerTime.invalidate()
           self.timerValue = 0
       }
       
       if (self.cID != ""){
           let param = ["isOnCall":true,"otherUserId":self.cID] as [String : Any]
           LoggedInRequest().updateCallStatus(params: param) { response, error in
               print(response)
           }
       }else{
           let param = ["isOnCall":true,"otherUserId":self.bookingId] as [String : Any]
           LoggedInRequest().updateCallStatus(params: param) { response, error in
               print(response)
           }

       }
       
       let sendMessageData = ["type":"voiceCall","senderId":Storage.shared.readUser()?.userId ?? "","receiverId":cID,"status":"connected"]
       Socketton.shared.sendConnect(json: sendMessageData )
       
       ringerTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playTimer), userInfo: nil, repeats: true)

       
       guard #available(iOS 13, *) else {
           incomingPushHandled()
           return
       }
   }
}


extension VoiceCallVC: PushKitEventDelegate {
func credentialsUpdated(credentials: PKPushCredentials) {
    guard
        (registrationRequired() || UserDefaults.standard.data(forKey: kCachedDeviceToken) != credentials.token)
    else {
        return
    }

    let cachedDeviceToken = credentials.token
    /*
     * Perform registration if a new device token is detected.
     */
    TwilioVoiceSDK.register(accessToken: Constant.appDelegate.twilioVoiceToken, deviceToken: cachedDeviceToken) { error in
        if let error = error {
            NSLog("An error occurred while registering: \(error.localizedDescription)")
        } else {
            NSLog("Successfully registered for VoIP push notifications.")
            
            // Save the device token after successfully registered.
            UserDefaults.standard.set(cachedDeviceToken, forKey: self.kCachedDeviceToken)
            
            /**
             * The TTL of a registration is 1 year. The TTL for registration for this device/identity
             * pair is reset to 1 year whenever a new registration occurs or a push notification is
             * sent to this device/identity pair.
             */
            UserDefaults.standard.set(Date(), forKey: self.kCachedBindingDate)
        }
    }
}

/**
 * The TTL of a registration is 1 year. The TTL for registration for this device/identity pair is reset to
 * 1 year whenever a new registration occurs or a push notification is sent to this device/identity pair.
 * This method checks if binding exists in UserDefaults, and if half of TTL has been passed then the method
 * will return true, else false.
 */
func registrationRequired() -> Bool {
    guard
        let lastBindingCreated = UserDefaults.standard.object(forKey: kCachedBindingDate)
    else { return true }
    
    let date = Date()
    var components = DateComponents()
    components.setValue(kRegistrationTTLInDays/2, for: .day)
    let expirationDate = Calendar.current.date(byAdding: components, to: lastBindingCreated as! Date)!

    if expirationDate.compare(date) == ComparisonResult.orderedDescending {
        return false
    }
    return true;
}

func credentialsInvalidated() {
    guard let deviceToken = UserDefaults.standard.data(forKey: kCachedDeviceToken) else { return }
    
    TwilioVoiceSDK.unregister(accessToken: Constant.appDelegate.twilioVoiceToken, deviceToken: deviceToken) { error in
        if let error = error {
            NSLog("An error occurred while unregistering: \(error.localizedDescription)")
        } else {
            NSLog("Successfully unregistered from VoIP push notifications.")
        }
    }
    
    UserDefaults.standard.removeObject(forKey: kCachedDeviceToken)
    
    // Remove the cached binding as credentials are invalidated
    UserDefaults.standard.removeObject(forKey: kCachedBindingDate)
}

func incomingPushReceived(payload: PKPushPayload) {
    // The Voice SDK will use main queue to invoke `cancelledCallInviteReceived:error:` when delegate queue is not passed
    TwilioVoiceSDK.handleNotification(payload.dictionaryPayload, delegate: self, delegateQueue: nil)
}

func incomingPushReceived(payload: PKPushPayload, completion: @escaping () -> Void) {
    // The Voice SDK will use main queue to invoke `cancelledCallInviteReceived:error:` when delegate queue is not passed
    TwilioVoiceSDK.handleNotification(payload.dictionaryPayload, delegate: self, delegateQueue: nil)
    
    if let version = Float(UIDevice.current.systemVersion), version < 13.0 {
        // Save for later when the notification is properly handled.
        incomingPushCompletionCallback = completion
    }
}

func incomingPushHandled() {
    guard let completion = incomingPushCompletionCallback else { return }
    
    incomingPushCompletionCallback = nil
    completion()
}
}
