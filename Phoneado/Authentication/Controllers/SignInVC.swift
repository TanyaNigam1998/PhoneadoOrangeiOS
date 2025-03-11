//
//  SignInVC.swift
//  Phoneado
//
//  Created by Zimble on 3/24/22.
//

import UIKit
import OTPFieldView
import ADCountryPicker
import Alamofire

class SignInVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var loginPinView: OTPFieldView!
    @IBOutlet weak var accountSignUpLbl: UILabel!
    @IBOutlet weak var signInGradientView: GradientView!
    @IBOutlet weak var guestLbl: UILabel!
    @IBOutlet weak var adminLbl: UILabel!
    @IBOutlet weak var forgotPinLbl: UILabel!
    @IBOutlet weak var forgotPinBtn: UIButton!
    @IBOutlet weak var accountSignUpBtn: UIButton!
    @IBOutlet weak var selectedCountryImgView: UIImageView!
    @IBOutlet weak var enterNumberLbl: UITextField!
    @IBOutlet weak var signInViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var eyeBtn: UIButton!
    //MARK: - Variable
    var selectedLbl = "Admin"
    var selectedCountryDialCode = "+1"
    var userLoginData: UserSignInModel?
    var userPassword = String()
    var startEditing: Bool = false
    var hasEnterd: Bool = false
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        
        // Do any additional setup after loading the view.
#if DEV
        self.enterNumberLbl.text = "9293127005"
        //        userPassword = "2305"
        print("dev")
#endif
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        signInView.layer.cornerRadius = 30
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: accountSignUpLbl.text ?? "")
        attributedString.setColorForText(textForAttribute: "Sign Up", withColor: UIColor(named: "AppColor") ?? UIColor.black)
        accountSignUpLbl.attributedText = attributedString
        signInView.applyDropShadowShadow()
        signInGradientView.gradientLayer.cornerRadius = signInGradientView.bounds.height / 2
        signInGradientView.layer.cornerRadius = signInGradientView.bounds.height / 2
        enterNumberLbl.delegate = self
        configurePinView()
    }
    func configurePinView() {
        self.loginPinView.secureEntry = true
        self.loginPinView.fieldsCount = 4
        self.loginPinView.fieldBorderWidth = 1
        self.loginPinView.fieldSize = 25
        self.loginPinView.defaultBorderColor = UIColor.lightGray
        self.loginPinView.clipsToBounds = true
        self.loginPinView.filledBorderColor = UIColor.black
        self.loginPinView.cursorColor = .appThemeColor
        self.loginPinView.displayType = .underlinedBottom
        self.loginPinView.shouldAllowIntermediateEditing = false
        self.loginPinView.delegate = self
        self.loginPinView.initializeUI()
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    func didFinishEnteringPin(pin: String) {
        let pin = userPassword
        guard !pin.isEmpty else {
            print("Error")
            return
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
        }
    }
    //MARK: - IB Actions
    
    @IBAction func eyeBtnAction(_ sender: UIButton) {
        eyeBtn.isSelected.toggle()
        loginPinView.secureEntry = sender.isSelected
        loginPinView.reloadInputViews()
        for number in 0...4 {
            let numberBtn = loginPinView.viewWithTag(number) as? UITextField
            numberBtn?.isSecureTextEntry = sender.isSelected
        }

       
    }
    @IBAction func guestBtnTapped(_ sender: Any) {
        guestLbl.textColor = UIColor(named: "AppColor")
        guestLbl.font = UIFont(name: "Lato-Bold", size: 18)
        adminLbl.textColor = UIColor(named: "DarkGrayTextColor")
        adminLbl.font = UIFont(name: "Lato-Regular", size: 18)
        forgotPinLbl.isHidden = true
        forgotPinBtn.isEnabled = false
        accountSignUpLbl.isHidden = true
        accountSignUpBtn.isEnabled = false
        selectedLbl = "\(guestLbl.text ?? "")"
    }
    @IBAction func adminBtnTapped(_ sender: Any) {
        guestLbl.textColor = UIColor(named: "DarkGrayTextColor")
        guestLbl.font = UIFont(name: "Lato-Regular", size: 18)
        adminLbl.textColor = UIColor(named: "AppColor")
        adminLbl.font = UIFont(name: "Lato-Bold", size: 18)
        forgotPinLbl.isHidden = false
        forgotPinBtn.isEnabled = true
        accountSignUpLbl.isHidden = false
        accountSignUpBtn.isEnabled = true
        selectedLbl = "\(adminLbl.text ?? "")"
    }
    
    @IBAction func forgotPinTapped(_ sender: Any) {
        let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "ForgotPinVC") as! ForgotPinVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if selectedLbl == "Guest" {
            if enterNumberLbl.text?.isEmpty == true {
                self.show(message:TaostMessages.emptyPhoneNumber, controller: self)
            } else if enterNumberLbl.text!.count < 10 || enterNumberLbl.text!.count > 10 {
                self.show(message: TaostMessages.invalidPhoneNumber, controller: self)
            } else if userPassword.count < 4 {
                self.show(message:TaostMessages.invalidPinEntered, controller: self)
            } else {
                let userMobileNumber = "\(selectedCountryDialCode)\(enterNumberLbl.text ?? "")"
                let requestDict = ["mobile": userMobileNumber,
                                   "password": userPassword,
                                   "deviceToken": SaveToken.deviceToken ?? "",
                                   "userLoginType": selectedLbl]
                userSignInRequest(requestParams: requestDict)
            }
        } else {
            if enterNumberLbl.text?.isEmpty == true {
                self.show(message: TaostMessages.emptyPhoneNumber, controller: self)
            } else if enterNumberLbl.text!.count < 10 || enterNumberLbl.text!.count > 10 {
                self.show(message: TaostMessages.invalidPhoneNumber, controller: self)
            } else if userPassword.count < 4 {
                self.show(message: TaostMessages.invalidPinEntered, controller: self)
            } else {
                let userMobileNumber = "\(selectedCountryDialCode)\(enterNumberLbl.text ?? "")"
                let requestDict = ["mobile": userMobileNumber,
                                   "password": userPassword,
                                   "deviceToken": SaveToken.deviceToken ?? "",
                                   "userLoginType": selectedLbl]
                userSignInRequest(requestParams: requestDict)
            }
        }
    }
    
    @IBAction func selectCountryTapped(_ sender: Any) {
        let picker = ADCountryPicker(style: .grouped)
        picker.delegate = self
        picker.showCallingCodes = true
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true)
    }
}
extension SignInVC: ADCountryPickerDelegate {
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String) {
        
    }
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        picker.navigationController?.dismiss(animated: true, completion: nil)
        if let flagImage = picker.getFlag(countryCode: code) {
            self.selectedCountryDialCode = dialCode
            selectedCountryImgView.image = flagImage
        }
    }
}
extension SignInVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == enterNumberLbl){
            let characterCountLimit = 10
            let startingLength = textField.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            return newLength <= characterCountLimit
        }
        return true
    }
}
//MARK: - Network request
extension SignInVC {
    func userSignInRequest(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().login(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                self.enterNumberLbl.text = ""
                Storage.shared.saveUser(user: UserDetail(response!))
                let user = Storage.shared.readUser()
                user?.userLoginType = self.selectedLbl
                Storage.shared.saveUser(user: user!)
                let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.userLoginType = self.selectedLbl
                Storage.shared.saveStatus(type: self.selectedLbl)
                Storage.shared.savephoneNumberr(type: (response! as NSDictionary).value(forKey: "mobile") as! String)
                UserDefaults.loggedInUserId = (response! as NSDictionary).value(forKey: "userId") as! String
                vc.isViaSignup = true
                self.navigationController?.pushViewController(vc, animated: true)
                NotificationCenter.default.post(name: Notification.Name.SigninNotification, object: nil, userInfo: ["UserLoginType": self.selectedLbl])
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}

extension SignInVC: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        self.hasEnterd = hasEntered
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        if self.startEditing {
            //            self.startEditing = false
            return true
        } else {
            self.startEditing = true
            return false
        }
    }
    
    func enteredOTP(otp otpString: String) {
        print("OTPString: \(otpString)")
        self.userPassword = otpString
    }
}
