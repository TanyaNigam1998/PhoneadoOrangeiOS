//
//  SignUpVC.swift
//  Phoneado
//
//  Created by Zimble on 3/24/22.
//

import UIKit
import ADCountryPicker
import SVProgressHUD
class SignUpVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var accountSignUpLbl: UILabel!
    @IBOutlet weak var signUpGradientView: GradientView!
    @IBOutlet weak var selectedCountryImgView: UIImageView!
    @IBOutlet weak var enterNumberLbl: UITextField!
    @IBOutlet weak var enterNameLbl: UITextField!
    //MARK: - Variable
    var imagePicker: ImagePicker!
    var imageUrl:String!

    @IBOutlet weak var profilePic: UIImageView!
    var selectedCountryDialCode = "+1"
    var userMobileNumber = ""
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.type = "picture"
        initialViewSetup()
        // Do any additional setup after loading the view.
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        outerView.layer.cornerRadius = 30
        signUpGradientView.gradientLayer.cornerRadius = signUpGradientView.bounds.height / 2
        signUpGradientView.layer.cornerRadius = signUpGradientView.bounds.height / 2
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: accountSignUpLbl.text ?? "")
        attributedString.setColorForText(textForAttribute: "Login", withColor: UIColor(named: "AppColor") ?? UIColor.black)
        accountSignUpLbl.attributedText = attributedString
        accountSignUpLbl.isUserInteractionEnabled = true
        accountSignUpLbl.addGestureRecognizer(getTapGesture())
        outerView.applyDropShadowShadow()
//        outerView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.15), opacity: 1, offSet:CGSize(width: -1, height: 1), radius: 30, scale: false)
        enterNumberLbl.delegate = self
        enterNameLbl.delegate = self
    }
    func getTapGesture() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchAction))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }
    //MARK: - IB Actions
    
    @IBAction func uploadImageAction(_ sender: UIButton) {
        self.imagePicker.present(from: sender)

    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc public func touchAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func signUpBtnTapped(_ sender: Any) {
        if enterNameLbl.text?.isEmpty == true {
            self.show(message:"Please enter your name.", controller: self)
        }else if enterNumberLbl.text?.isEmpty == true {
            self.show(message:TaostMessages.emptyPhoneNumber, controller: self)
        }else {
            UserDefaults.standard.set(enterNameLbl.text ?? "", forKey: UserDefault.signUpUserName)
            self.userMobileNumber = "\(selectedCountryDialCode)\(enterNumberLbl.text ?? "")"
            UserDefaults.standard.set(self.userMobileNumber, forKey: UserDefault.signUpMobileNumber)
            UserDefaults.standard.set(self.imageUrl, forKey: UserDefault.profilePic)
            UserDefaults.standard.set(self.selectedCountryDialCode, forKey: "dialCode")
            let requestDict = ["mobile": self.userMobileNumber,
                               "type": OtpType.REGISTER_OTP]
            print("Create OTP Request Dict = \(requestDict)")
            createOTPRequest(requestParams: requestDict)
    }
    }
    @IBAction func selectCountryTapped(_ sender: Any) {
        let picker = ADCountryPicker(style: .grouped)
        picker.delegate = self
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension SignUpVC:ADCountryPickerDelegate {
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        picker.navigationController?.dismiss(animated: true, completion: nil)
        print("Selected Country Name = \(name),Selected Country Code = \(code),Selected Country Dial Code = \(dialCode)")
        if let flagImage = picker.getFlag(countryCode: code) {
            self.selectedCountryDialCode = dialCode
            self.selectedCountryImgView.image = flagImage
        }
    }
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String) {}
}
extension SignUpVC:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == enterNumberLbl) {
            let characterCountLimit = 10
            let startingLength = textField.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            return newLength <= characterCountLimit
        }else if (textField == enterNameLbl) {
            let characterCountLimit = 25
            let startingLength = textField.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            return newLength <= characterCountLimit
        }
        return true
    }
}
//MARK: - Network Requests
extension SignUpVC {
    func createOTPRequest(requestParams:[String:Any] = [:]) {
        guard let number = self.enterNumberLbl.text else {
            return
        }
        guard let enterName = self.enterNameLbl.text else {
            return
        }
        if number.isEmpty
        {
            Alert().showAlert(message: TextMessages.emptyEmail)
            return
        }
        else if enterName.isEmpty {
            Alert().showAlert(message: TextMessages.emptyUserName)
        }
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().createOTP(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                self.enterNumberLbl.text = ""
                self.enterNameLbl.text = ""
                let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
                vc.phoneNumber = self.userMobileNumber
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                    Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    func uploadProfilePicServiceReuqest(){
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        LoggedInRequest().uploadMultipleImages(images: [profilePic.image!]) { (response, error) in
             SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            if error == nil{
                if let data = response?["data"] as? Dictionary<String,Any>,let url = data["url"] as? String {
                    self.imageUrl = url
                }
            }else{
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    
}
extension SignUpVC: ImagePickerDelegate {
  func didSelect(image: UIImage?, data: Data?) {
      profilePic.image = image
      uploadProfilePicServiceReuqest()
  }
}
