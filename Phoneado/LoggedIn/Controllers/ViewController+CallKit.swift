//
//  ViewController+CallKit.swift
//  VideoCallKitQuickStart
//
//  Copyright © 2016-2019 Twilio, Inc. All rights reserved.
//

import UIKit

import TwilioVideo
import CallKit
import AVFoundation

extension ViewController  {
    
    //CXProviderDelegate

/*    func providerDidReset(_ provider: CXProvider) {
        logMessage(messageText: "providerDidReset:")

        // AudioDevice is enabled by default
        self.audioDevice.isEnabled = true
        
        room?.disconnect()
    }

    func providerDidBegin(_ provider: CXProvider) {
        logMessage(messageText: "providerDidBegin")
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        logMessage(messageText: "provider:didActivateAudioSession:")

        self.audioDevice.isEnabled = true
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        logMessage(messageText: "provider:didDeactivateAudioSession:")
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        logMessage(messageText: "provider:timedOutPerformingAction:")
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        logMessage(messageText: "provider:performStartCallAction:")

        /*
         * Configure the audio session, but do not start call audio here, since it must be done once
         * the audio session has been activated by the system after having its priority elevated.
         */

        // Stop the audio unit by setting isEnabled to `false`.
        self.audioDevice.isEnabled = false;

        // Configure the AVAudioSession by executign the audio device's `block`.
        self.audioDevice.block()

        callKitProvider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
        
        performRoomConnect(uuid: action.callUUID, roomName: action.handle.value) { (success) in
            if (success) {
                provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
                action.fulfill()
            } else {
                action.fail()
            }
        }
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        logMessage(messageText: "provider:performAnswerCallAction:")

        /*
         * Configure the audio session, but do not start call audio here, since it must be done once
         * the audio session has been activated by the system after having its priority elevated.
         */

        // Stop the audio unit by setting isEnabled to `false`.
        self.audioDevice.isEnabled = false;

        // Configure the AVAudioSession by executign the audio device's `block`.
        self.audioDevice.block()

     /*   performRoomConnect(uuid: action.callUUID, roomName:self.roomName) { (success) in
            if (success) {
                action.fulfill(withDateConnected: Date())
            } else {
                action.fail()
            }
        } */
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        NSLog("provider:performEndCallAction:")

         room?.disconnect()
         self.dismiss(animated: true, completion: nil)
        

        
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        NSLog("provier:performSetMutedCallAction:")
        
        muteAudio(isMuted: action.isMuted)
        
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        NSLog("provier:performSetHeldCallAction:")

        let cxObserver = callKitCallController.callObserver
        let calls = cxObserver.calls

        guard let call = calls.first(where:{$0.uuid == action.callUUID}) else {
            action.fail()
            return
        }

        if call.isOnHold {
            holdCall(onHold: false)
        } else {
            holdCall(onHold: true)
        }
        action.fulfill()
    } */
}

// MARK:- Call Kit Actions
extension ViewController {

 /*   func performStartCallAction(uuid: UUID, roomName: String?) {
        let callHandle = CXHandle(type: .generic, value: roomName ?? "")
        let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
        
        startCallAction.isVideo = true
        
        let transaction = CXTransaction(action: startCallAction)
        
        callKitCallController.request(transaction)  { error in
            if let error = error {
                NSLog("StartCallAction transaction request failed: \(error.localizedDescription)")
                return
            }
            NSLog("StartCallAction transaction request successful")
        }
    } */

  /*  func reportIncomingCall(uuid: UUID, roomName: String?, completion: ((NSError?) -> Void)? = nil) {
        let callHandle = CXHandle(type: .generic, value: roomName ?? "")

        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = callHandle
        callUpdate.supportsDTMF = false
        callUpdate.supportsHolding = true
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.hasVideo = true

        callKitProvider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
            if error == nil {
                NSLog("Incoming call successfully reported.")
            } else {
                NSLog("Failed to report incoming call successfully: \(String(describing: error?.localizedDescription)).")
            }
            completion?(error as NSError?)
        }
    } */

 /*   func performEndCallAction(uuid: UUID) {
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)

        if((room) != nil){
            room?.disconnect()
        }
        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("EndCallAction transaction request failed: \(error.localizedDescription).")
                return
            }

            NSLog("EndCallAction transaction request successful")
        }
    } */

 /*   func performRoomConnect(uuid: UUID, roomName: String? , completionHandler: @escaping (Bool) -> Swift.Void) {
        // Configure access token either from server or manually.
        // If the default wasn't changed, try fetching from server.
        if (accessToken == "TWILIO_ACCESS_TOKEN") {
            

                API.getToken(roomName: self.roomName, success: { (response) in
                   
                    print(response)
                    let dataDict = response.value(forKey: "data") as! NSDictionary
                    self.accessToken = dataDict.value(forKey: "token") as! String
                    Constant.KAppDelegate.hideProgressHUD()
                    // Prepare local media which we will share with Room Participants.
                    self.prepareLocalMedia()
                    // Preparing the connect options with the access token that we fetched (or hardcoded).
                    let connectOptions = ConnectOptions(token: self.accessToken) { (builder) in
                        
                                // Use the local media that we prepared earlier.
                                builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
                                builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
                                builder.roomName = roomName
                                builder.uuid = uuid
                    }
                            
                    // Connect to the Room using the options we provided.
                    self.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
                    self.logMessage(messageText: "Attempting to connect to room \(String(describing: roomName))")
                    self.showRoomUI(inRoom: true)
                    self.callKitCompletionHandler = completionHandler
                    
                    
                }) { (error) in
                    Constant.KAppDelegate.hideProgressHUD()
                }
                
              
                }

    } */
}
