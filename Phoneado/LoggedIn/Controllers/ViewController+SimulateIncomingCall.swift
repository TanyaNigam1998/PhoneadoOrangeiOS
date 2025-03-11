//
//  ViewController+SimulateIncomingCall.swift
//  VideoCallKitQuickStart
//
//  Copyright © 2016-2019 Twilio, Inc. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
//import FirebaseInstanceID
//import Firebase
//import fireba

// MARK:- Simulate Incoming Call
extension ViewController {

    func sendFCM() {


    }
    
    static func parseNotification(notification: UNNotification) -> String {
        return notification.request.content.title
    }
    

}
