//
//  ContactDetailsVC.swift
//  Phoneado
//
//  Created by Zimble on 3/29/22.
//

import UIKit

class ContactDetailsVC: UIViewController {
    //MARK: - IB Outlets
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var contactDetailView: UIView!
    @IBOutlet weak var contactNameLbl: UILabel!
    @IBOutlet weak var contactNumberLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dialCallButton: UIButton!
    @IBOutlet weak var dialVideoCallButton: UIButton!
    @IBOutlet weak var callHistoryView: UIView!
    //MARK: - Variable
    var contactName:String = ""
    var contactNumber:String = ""
    var ids:String?
    var profilePicUrl:String!
    var imageData:Data!
    var imageDataAvailable = false
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(disableBtn), name: NSNotification.Name(rawValue: "disable"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableBtn), name: NSNotification.Name(rawValue: "enable"), object: nil)
        
        if (Constant.appDelegate.isButtonEnable){
            self.dialCallButton.isHidden = false
            self.dialVideoCallButton.isHidden = false

        }else{
            self.dialCallButton.isHidden = true
            self.dialVideoCallButton.isHidden = true
        }
//        self.isMessageReceived()
        self.callHistoryView.isUserInteractionEnabled = true
        self.callHistoryView.addGestureRecognizer(getTapGesture())
        if !((profilePicUrl ?? "").isEmpty){
            profilePic.sd_setImage(with: URL(string: profilePicUrl ?? ""),placeholderImage: UIImage.init(named: "contact_avatar"))
        }else if imageDataAvailable{
            profilePic.image = UIImage.init(data: imageData )
        }else{
            profilePic.image = UIImage.init(named: "contact_avatar")
        }
        profilePic.layer.cornerRadius = profilePic.frame.size.height/2
    }
    
    func isMessageReceived() {
        Socketton.shared.isVoiceIncoming = { json in
            print(json)
            print("Message Json = \(json)")
            if self.viewIfLoaded?.window != nil {
               let chat = ChatData(json)
                if chat.senderId == self.contactNumber {
                    
                    self.dialCallButton.isHidden = true
                    self.dialVideoCallButton.isHidden = true
                    
                }
            }
        }
    }

    func getTapGesture() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchAction))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }
    
    @objc public func touchAction() {
        self.getUserProfile()
    }
    
    @objc private func disableBtn(notification: NSNotification){
        
        self.dialCallButton.isHidden = true
        self.dialVideoCallButton.isHidden = true
    }
    
    @objc private func enableBtn(notification: NSNotification){
        self.dialCallButton.isHidden = false
        self.dialVideoCallButton.isHidden = false
    }
    
    func getUserProfile() {
        let plusNumber = self.contactNumber.replacingOccurrences(of: "+", with: "")
        let bracketStartNumber = plusNumber.replacingOccurrences(of: "(", with: "")
        let bracketCloseNumber = bracketStartNumber.replacingOccurrences(of: ")", with: "")
        let number = bracketCloseNumber.replacingOccurrences(of: "-", with: "")
        let phoneNumber = number.removingWhitespaces()
        print("phoneNumber", phoneNumber)
        
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getProfile(number: phoneNumber, params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil
            {
                print("response", response ?? [:])
                let res: [String: Any] = response!["data"] as! [String : Any]
                print("res", res["userId"] ?? "")
                
                self.ids = res["userId"] as? String
                
                print("userId", self.ids ?? "")
                let vc = CallLogsVC.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
                vc.userId = self.ids ?? ""
                vc.fromContactDetail = true
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else
            {
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }

    //MARK: - Required Methods
    func initialViewSetup() {
//        if let name = contactName {
        contactNameLbl.text = contactName
//        }
//        if let contactNumber = contactNumber {
        contactNumberLbl.text = contactNumber
//        }
//        contactDetailView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.18), opacity: 0.4, offSet:CGSize(width: -1, height: 1), radius: 20, scale: false)
        contactDetailView.layer.cornerRadius = 15
        contactDetailView.applyDropShadowShadow()
        
        self.backButton.setTitle("", for: .normal)
    }
    //MARK: - IB Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func messageTapped(_ sender: Any) {
        
        
        var requestDict = [String:Any]()
        
        let str = self.contactNumberLbl.text!
        var number:String!
        
        if (str.contains("+")){
            number = self.contactNumberLbl.text!
        }else{
            number = "+1\( self.contactNumberLbl.text!)"
        }
        
        let mobileDict:[String:Any] = ["mobile":number!]
        var arrDict = [Any]()
        arrDict.append(mobileDict)
        requestDict = ["mobileList":arrDict]
        
        let mobileNumber = Storage.shared.getPhoneNumber()
        
        var newNumber = number.replacingOccurrences(of: " ", with: "")
        newNumber = newNumber.replacingOccurrences(of: "(", with: "")
        newNumber = newNumber.replacingOccurrences(of: ")", with: "")

        if (mobileNumber == newNumber){
            
            Alert().showAlert(message:"User can not call on same number")
            return

        }
        
        
        var requestDict1 = [String:Any]()
        let mobileDict1:[String:Any] = ["mobile":self.contactNumberLbl.text ?? ""]
        var arrDict1 = [Any]()
        arrDict1.append(mobileDict1)
        requestDict1 = ["mobileList":arrDict1]
        print("Check Mobile Dict = \(requestDict1)")
        checkRegisteredMobileRequest(requestParams: requestDict1)
    }
    @IBAction func videoCallTapped(_ sender: Any) {
        
        var requestDict = [String:Any]()
        let str = self.contactNumberLbl.text!
        var number:String!
        
        if (str.contains("+")){
            number = self.contactNumberLbl.text!
        }else{
            number = "+1\( self.contactNumberLbl.text!)"
        }

        let mobileDict:[String:Any] = ["mobile":number!]
        var arrDict = [Any]()
        arrDict.append(mobileDict)
        requestDict = ["mobileList":arrDict]
        let mobileNumber = Storage.shared.getPhoneNumber()
        
        var newNumber = number.replacingOccurrences(of: " ", with: "")
        newNumber = newNumber.replacingOccurrences(of: "(", with: "")
        newNumber = newNumber.replacingOccurrences(of: ")", with: "")

        if (mobileNumber == newNumber){
            
            Alert().showAlert(message:"User can not call on same number")
            return

        }


        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().checkRegisteredMobileRequest(params: requestDict) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else {return}
                do {
                    let responseData = try JSONDecoder().decode(CheckContactsModel.self, from: data)
                    if responseData.data.mobileList[0].userId.isEmpty {
                        self.show(message: "This user is not registered yet.", controller: self)
                    } else {
                        let  data = (response! as NSDictionary).value(forKey: "data") as! NSDictionary
                        let array = data.value(forKey: "mobileList") as! NSArray
                        let newDict = array[0] as! NSDictionary
                        let userId = newDict.value(forKey: "userId") as! String
                        
                        if newDict.value(forKey: "isCalling") as? Bool != nil {
                            let isCalling = newDict.value(forKey: "isCalling") as! Bool
                            if (isCalling) {
                              Alert().showAlert(message: "This user is busy on another call. Please try later")
                            } else {
                                let vc = VideoVC()
                                vc.bookingId = userId
                                vc.celeName  = self.contactName
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else {
                            let vc = VideoVC()
                            vc.bookingId = userId
                            vc.celeName  = self.contactName
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                } catch let err {
                    print("Error = \(err)")
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    
    @IBAction func callTapped(_ sender: Any) {
        
               
        var requestDict = [String:Any]()
        
        let str = self.contactNumberLbl.text!
        var number:String!
        
        if (str.contains("+")){
            number = self.contactNumberLbl.text!
        }else{
            number = "+1\( self.contactNumberLbl.text!)"
        }

        
        let mobileDict:[String:Any] = ["mobile":number!]
        var arrDict = [Any]()
        arrDict.append(mobileDict)
        requestDict = ["mobileList":arrDict]
        
        
        let mobileNumber = Storage.shared.getPhoneNumber()
        
        var newNumber = number.replacingOccurrences(of: " ", with: "")
        newNumber = newNumber.replacingOccurrences(of: "(", with: "")
        newNumber = newNumber.replacingOccurrences(of: ")", with: "")

        if (mobileNumber == newNumber){
            
            Alert().showAlert(message:"User can not call on same number")
            return

        }

        
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().checkRegisteredMobileRequest(params: requestDict) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else {return}
                do {
                    let responseData = try JSONDecoder().decode(CheckContactsModel.self, from: data)
                    if responseData.data.mobileList[0].userId.isEmpty {
                        self.show(message: "This user is not registerd yet.", controller: self)
                    }else {
                        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "VoiceCallVC") as! VoiceCallVC
                        
                        let  data = (response! as NSDictionary).value(forKey: "data") as! NSDictionary
                        let array = data.value(forKey: "mobileList") as! NSArray
                        let newDict = array[0] as! NSDictionary
                        
                        if newDict.value(forKey: "isCalling") as? Bool != nil{
                            let isCalling = newDict.value(forKey: "isCalling") as! Bool
                            if (isCalling){
                                
                                Alert().showAlert(message: "This user is busy on another call. Please try later")
                                
                            }else{
                         
                                vc.cID = newDict.value(forKey: "userId") as! String
                                vc.celeName = self.contactName ?? ""
                                self.navigationController?.pushViewController(vc, animated: true)

                            }

                        }else{
                            vc.cID = newDict.value(forKey: "userId") as! String
                            vc.celeName = self.contactName ?? ""
                            self.navigationController?.pushViewController(vc, animated: true)

                        }

                        
                        
                    }
                }catch let err {
                    print("Error = \(err)")
                }
                
            }
            else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
extension ContactDetailsVC {
    func checkRegisteredMobileRequest(requestParams:[String:Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().checkRegisteredMobileRequest(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else {return}
                do {
                    let responseData = try JSONDecoder().decode(CheckContactsModel.self, from: data)
                    if responseData.data.mobileList[0].userId.isEmpty {
                        self.show(message: "This user is not registerd yet.", controller: self)
                    }else {
                        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "IndividualChatDetailVC") as! IndividualChatDetailVC
                        vc.individualName = self.contactNameLbl.text ?? ""
                        vc.isViaDetail = true
                        vc.toID = responseData.data.mobileList[0].userId
                        print("To Id = \(responseData.data.mobileList[0].userId)")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }catch let err {
                    print("Error = \(err)")
                }
                
            }
            else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
