//
//  LocationManager.swift
//  EveryonesaCritic
//
//  Created by TJSingh on 13/05/19.
//  Copyright © 2019 ZimbleCode. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
class LocationManager: NSObject,CLLocationManagerDelegate {
    static var shared = LocationManager()
    var locationManager = CLLocationManager()
    var completitionClosure: ((Bool) -> Void)?
     var lastTimestamp: Date?
    var lastSavedLoc:CLLocation!
    var locationCompletitionClosure: ((CLLocation?) -> Void)?
    func intialiseLocationManager(completitionHandler:((Bool) -> Void)?) {
        completitionClosure = completitionHandler
        let statuss = CLLocationManager.authorizationStatus()
        if statuss == .notDetermined || statuss == .denied {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.delegate = self
        self.startLocationUpdation()
    }
   func startLocationUpdation() {
          locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
          locationManager.allowsBackgroundLocationUpdates = true
          locationManager.pausesLocationUpdatesAutomatically=false
          locationManager.startUpdatingLocation()
      }
      func stopUpdatingLocation(){
          locationManager.stopUpdatingLocation()
      }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse,.authorizedAlways:
            if (completitionClosure != nil){
                completitionClosure!(true)
            }
            break
        case .denied,.notDetermined, .restricted:
          //  Alert().showAlert(message: HMessage.locationDenied)
            break
        default: break
        }
    }
    func checkLocationAuthorization(completitionHandler:((Bool) -> Void)?){
        completitionClosure = completitionHandler
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                 completitionClosure!(false)
               print("notDetermined")
                 break
            case .restricted, .denied:
                print("restricted")
               // print("No access")
//                Alert().showAlertWithAction(title: "", message: "Please enable your Location Services", buttonTitle: "Enable", secondBtnTitle: "Cancel", withCallback: {
//                    if let bundleId = Bundle.main.bundleIdentifier,
//                        let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
//                    {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }) {}
                completitionClosure!(false)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                if (completitionClosure != nil){
                    completitionClosure!(true)
                }
            @unknown default:
                break
            }
        } else {
//            Alert().showAlertWithAction(title: "", message: "Please enable your Location Services", buttonTitle: "Enable", secondBtnTitle: "", withCallback: {
//
//                if let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION_SERVICES") {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//            }) {}
             completitionClosure!(false)
            print("Location services are not enabled")
        }
    }
    func fetchCurrentLocation(completitionHandler:((CLLocation?) -> Void)?){
        locationCompletitionClosure = completitionHandler
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationCompletitionClosure != nil{
            locationCompletitionClosure!(locations.first)
        }
        let now = Date()
        let interval = TimeInterval((lastTimestamp != nil) ? now.timeIntervalSince(lastTimestamp!) : 0.0)
//        print("interval", interval)
        let user = Storage.shared.readUser()
        let timeInterval = user?.locationUpdateTime ?? 0
//        print("TimeInterval", timeInterval)
        if !(lastTimestamp != nil) || interval >= timeInterval {
            lastTimestamp = now
            self.updateUserLocation(loc: locations.last!)
        }
    }
    func updateUserLocation(loc:CLLocation){
        let user = Storage.shared.readUser()
        let userLoginType = user?.userLoginType ?? ""
        if userLoginType == "Admin"{
            var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
            lastSavedLoc = loc
            
            LoggedInRequest().updateUser(params: ["location":["lat":loc.coordinate.latitude,"lng":loc.coordinate.longitude], "isLocationUpdateRequired": true]) { (response, error) in
                if error == nil
                {
                    print("Location Updated", response)
                } else {
                    Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
                }
            }

        }
    }
}
