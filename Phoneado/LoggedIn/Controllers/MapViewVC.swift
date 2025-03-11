//
//  MapViewVC.swift
//  Phoneado
//
//  Created by Deviser M1 Pro on 27/03/24.
//

import UIKit
import GoogleMaps

class MapViewVC: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var latlongView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var latLongLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var marker = GMSMarker()
    var  timer = Timer()
    var  globalLat = Double()
    var  globalLng = Double()
    var defaultTime = 9.0
    var soundTimer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        addressView.clipsToBounds = true
        addressView.layer.cornerRadius = 5
        latLongLbl.clipsToBounds = true
        latLongLbl.layer.cornerRadius = 5
        self.mapView.isMyLocationEnabled = false
        self.mapView.settings.myLocationButton = false
        self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        self.getUserProfile()

        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
        soundTimer.invalidate()
    }
    @objc func update() {
        self.getUserProfile()
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return false
    }
    func getUserProfile() {
        LoggedInRequest().getUserProfile(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                print("response", response ?? [:])
                let res: [String: Any] = response!["data"] as! [String : Any]
                print("res", res)
                let user = Storage.shared.readUser()
                let lastLocation = res["lastLocation"] as? [String: Any]
                if ((lastLocation!["lat"] as? Double) != nil){
                    let lat = lastLocation!["lat"] as! Double
                    let lng = lastLocation!["lng"] as! Double
                    self.globalLat = lastLocation!["lat"] as! Double
                    self.globalLng = lastLocation!["lng"] as! Double
                    let address = CLGeocoder.init()
                    address.reverseGeocodeLocation(CLLocation.init(latitude: lat, longitude: lng)) { (places, error) in
                        if error == nil {
                            if let place = places {
                                let placeMark = places! as [CLPlacemark]
                                if placeMark.count > 0 {
                                    let placeMark = places![0]
                                    var addressString: String = ""
                                    if placeMark.subThoroughfare != nil {
                                        addressString = addressString + placeMark.subThoroughfare! + ", "
                                    }
                                    if placeMark.thoroughfare != nil {
                                        addressString = addressString + placeMark.thoroughfare! + ", "
                                    }
                                    if placeMark.subLocality != nil {
                                        addressString = addressString + placeMark.subLocality! + ", "
                                    }
                                    if placeMark.locality != nil {
                                        addressString = addressString + placeMark.locality! + ", "
                                    }
                                    if placeMark.country != nil {
                                        addressString = addressString + placeMark.country! + ", "
                                    }
                                    self.addressLbl.text = addressString
                                    self.latLongLbl.text = "\(lat),\(lng)"
                                }
                            }
                        }
                        self.mapView.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15)
                        let loc = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        self.marker.position = loc
                        self.marker.map = self.mapView
                        self.marker.icon = UIImage(named: "location_pin")
                    }
                }
            }
        }
    }
    
    @IBAction func playSoundAction(_ sender: UIButton) {
        playSoundNotificationServiceRequest()
        playBtn.setTitle("Playing...", for: .normal)
        playBtn.backgroundColor = .gray
        playBtn.isUserInteractionEnabled = false
        soundTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.action), userInfo: nil, repeats: true)
      
    }
    @objc func action() {
        if defaultTime == 0.0 {
            soundTimer.invalidate()
            defaultTime = 10
            self.playBtn.setTitle("Play Sound", for: .normal)
            self.playBtn.backgroundColor = .orange
            self.playBtn.isUserInteractionEnabled = true
        } else {
            playBtn.setTitle("Playing...", for: .normal)
            playBtn.backgroundColor = .gray
            playBtn.isUserInteractionEnabled = false
        }
        defaultTime -= 1
    }
    
    func openGoogleMap() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(globalLat),\(globalLng)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            //Open in browser
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(globalLat),\(globalLng)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
    }

    @IBAction func locationButtonClicked(_ sender: UIButton) {
        self.openGoogleMap()
    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func playSoundNotificationServiceRequest() {
        LoggedInRequest().playSound(params: [:]) { response, error in}
    }
}
