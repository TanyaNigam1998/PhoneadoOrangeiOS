//
//  VerificationCodeVC.swift
//  Phoneado
//
//  Created by Zimble on 4/7/22.
//

import UIKit
import SVPinView
import OTPFieldView

class VerificationCodeVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var verificationPinCodeView: OTPFieldView!
    @IBOutlet weak var verifyBtnView: GradientView!
    @IBOutlet weak var resendOtpLbl: UILabel!
    @IBOutlet weak var buttonResend: UIButton!
    @IBOutlet weak var LblCountdown: UILabel!
    //MARK: - Variable
    var phoneNumber:String?
    var otpToken: Int?
    var verifyOtpData:VerifyOTPData?
    var enteredOTP: String = ""
    var startEditing: Bool = false
    var fromEditPhoneController: Bool = false
    var fromForgotVC: Bool = false
    var hasEnteredOTP: Bool = false
    var count = 30
    var resendTimer = Timer()
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        // Do any additional setup after loading the view.
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        outerView.layer.cornerRadius = 30
        verifyBtnView.gradientLayer.cornerRadius = verifyBtnView.bounds.height / 2
        verifyBtnView.layer.cornerRadius = verifyBtnView.bounds.height / 2
        outerView.applyDropShadowShadow()
//        outerView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.15), opacity: 1, offSet:CGSize(width: -1, height: 1), radius: 30, scale: false)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: resendOtpLbl.text ?? "")
        attributedString.setColorForText(textForAttribute: "Resend OTP", withColor: UIColor(named: "AppColor") ?? UIColor.black)
        resendOtpLbl.attributedText = attributedString
        
        DispatchQueue.main.async {
            self.configurePinView()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.resendTimer.isValid
        {
            self.resendTimer.invalidate()
        }
    }
    
    func ScheduleTimer()
    {
        self.resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    //MARK:- update Timer
    @objc func update() {
        if(count > 0) {
            count = count - 1
            
            print(count)
            self.LblCountdown.text = String(format: "(00.%02d)", count)
            self.buttonResend.isEnabled = false
        }
        else {
            self.buttonResend.isEnabled = true
            resendTimer.invalidate()
        }
    }
    func configurePinView() {
//        verificationPinCodeView.pinLength = 4
//        verificationPinCodeView.secureCharacter = "\u{25CF}"
//        verificationPinCodeView.interSpace = 10
//        verificationPinCodeView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
//        verificationPinCodeView.borderLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
//        verificationPinCodeView.activeBorderLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
//        verificationPinCodeView.borderLineThickness = 2
//        verificationPinCodeView.shouldSecureText = true
//        verificationPinCodeView.allowsWhitespaces = false
//        verificationPinCodeView.style = .box
//        verificationPinCodeView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
//        verificationPinCodeView.activeFieldBackgroundColor = UIColor.gray.withAlphaComponent(0.3)
//        verificationPinCodeView.fieldCornerRadius = 15
//        verificationPinCodeView.activeFieldCornerRadius = 15
//        verificationPinCodeView.placeholder = ""
//        verificationPinCodeView.deleteButtonAction = .deleteCurrentAndMoveToPrevious
//        verificationPinCodeView.keyboardAppearance = .default
//        verificationPinCodeView.tintColor = .white
//        verificationPinCodeView.becomeFirstResponderAtIndex = 4
//        verificationPinCodeView.shouldDismissKeyboardOnEmptyFirstField = true
//        verificationPinCodeView.font = UIFont.systemFont(ofSize: 15)
//        verificationPinCodeView.keyboardType = .phonePad
//        verificationPinCodeView.pinInputAccessoryView = { () -> UIView in
//            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
//            doneToolbar.barStyle = UIBarStyle.default
//            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(dismissKeyboard))
//            var items = [UIBarButtonItem]()
//            items.append(flexSpace)
//            items.append(done)
//            doneToolbar.items = items
//            doneToolbar.sizeToFit()
//            return doneToolbar
//        }()
//        verificationPinCodeView.didFinishCallback = didFinishEnteringPin(pin:)
//        verificationPinCodeView.didChangeCallback = { pin in
//            print("The entered pin is \(pin)")
//        }
//        verificationPinCodeView.activeBorderLineThickness = 1
//        verificationPinCodeView.fieldBackgroundColor = UIColor.clear
//        verificationPinCodeView.activeFieldBackgroundColor = UIColor.clear
//        verificationPinCodeView.fieldCornerRadius = 0
//        verificationPinCodeView.activeFieldCornerRadius = 0
//        verificationPinCodeView.style = .none
        
        self.verificationPinCodeView.secureEntry = true
        self.verificationPinCodeView.fieldsCount = 4
        self.verificationPinCodeView.fieldBorderWidth = 1
        self.verificationPinCodeView.fieldSize = 40
        self.verificationPinCodeView.defaultBorderColor = UIColor.lightGray
        self.verificationPinCodeView.clipsToBounds = true
        self.verificationPinCodeView.filledBorderColor = UIColor.black
        self.verificationPinCodeView.cursorColor = .appThemeColor
        self.verificationPinCodeView.displayType = .underlinedBottom
        self.verificationPinCodeView.shouldAllowIntermediateEditing = false
        self.verificationPinCodeView.delegate = self
        self.verificationPinCodeView.initializeUI()
        self.LblCountdown.text = "(00:00)"
        self.ScheduleTimer()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
        self.startEditing = true
        self.view.endEditing(true)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    func didFinishEnteringPin(pin:String) {
        let pin = self.enteredOTP
        guard !pin.isEmpty else {
            print("Error")
            return
        }
        print("Entered Pin = \(pin)")
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: - IB Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        if fromEditPhoneController{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func verifyNowTapped(_ sender: Any) {
        if self.enteredOTP.count < 4 {
            self.show(message:"Please enter valid OTP.", controller:self)
        }
        else if !self.hasEnteredOTP
        {
            self.show(message:"Please enter OTP.", controller:self)
        }
        else {
            if fromEditPhoneController
            {
                if let enteredOtp = Int(self.enteredOTP)
                {
                    let requestDict:[String:Any] = ["mobile": self.phoneNumber ?? "",
                                       "type": OtpType.MOBILE_UPDATE_OTP,
                                                    "otp": enteredOtp]
                    print("Verify OTP Request Dict = \(requestDict)")
                    verifyOTPRequest(requestParams: requestDict )
                }
            }else if fromForgotVC
            {
                if let enteredOtp = Int(self.enteredOTP)
                {
                    let requestDict:[String:Any] = ["mobile": self.phoneNumber ?? "",
                                       "type": OtpType.FORGOT_OTP,
                                                    "otp": enteredOtp]
                    print("Verify OTP Request Dict = \(requestDict)")
                    verifyOTPRequest(requestParams: requestDict )
                }
            }else{
                if let enteredOtp = Int(self.enteredOTP)
                {
                    let requestDict:[String:Any] = ["mobile": self.phoneNumber ?? "",
                                       "type": OtpType.REGISTER_OTP,
                                                    "otp": enteredOtp]
                    print("Verify OTP Request Dict = \(requestDict)")
                    verifyOTPRequest(requestParams: requestDict )
                }
            }
            
    }
    }
    @IBAction func resendOtpTapped(_ sender: Any) {
        self.count = 30
        if self.resendTimer.isValid
        {
            self.resendTimer.invalidate()
        }
        self.ScheduleTimer()
        if fromEditPhoneController{
            let requestDict:[String:Any] = ["mobile": self.phoneNumber ?? "",
                               "type": OtpType.MOBILE_UPDATE_OTP]
            print("Create OTP Request Dict = \(requestDict)")
            createOTPRequest(requestParams: requestDict)
        }else if fromForgotVC{
            let requestDict:[String:Any] = ["mobile": self.phoneNumber ?? "",
                               "type": OtpType.FORGOT_OTP]
            print("Create OTP Request Dict = \(requestDict)")
            createOTPRequest(requestParams: requestDict)
        }else{
            let requestDict:[String:Any] = ["mobile": self.phoneNumber ?? "",
                               "type": OtpType.REGISTER_OTP]
            print("Create OTP Request Dict = \(requestDict)")
            createOTPRequest(requestParams: requestDict)
        }
        
    }
}
extension VerificationCodeVC {
    func verifyOTPRequest(requestParams:[String:Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().verify(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                if self.resendTimer.isValid
                {
                    self.resendTimer.invalidate()
                }
                if let data = response {
                    if let otpToken = data["token"] {
                        UserDefaults.standard.set(otpToken, forKey: UserDefault.verifyOTPToken)
                        self.otpToken = (otpToken as! Int)
                    }
                    if let otpType = data["type"] {
                        UserDefaults.standard.set(otpType, forKey: UserDefault.verifyOTPType)
                    }
                    print("data token = \(UserDefaults.standard.string(forKey: UserDefault.verifyOTPToken) ?? "")")
                    print("data type = \(UserDefaults.standard.string(forKey: UserDefault.verifyOTPType) ?? "")")
                }
                
                if self.fromEditPhoneController{
                    self.updateUser()
                }else if self.fromForgotVC{
                    let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SignUpPinVC") as! SignUpPinVC
                    vc.oTpToken = self.otpToken
                    vc.mobile = self.phoneNumber ?? ""
                    vc.fromForgotVC = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SignUpPinVC") as! SignUpPinVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else
            {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    func createOTPRequest(requestParams:[String:Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().createOTP(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                Alert().showAlert(message: "Verification code generated successfully.")
            }
            else
            {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    func updateUser()
    {
        var parm: [String:Any] = [:]
        parm.updateValue(self.phoneNumber ?? "", forKey: "mobile")
        parm.updateValue(self.otpToken ?? "", forKey: "otpToken")

        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().updateUser(params: parm){ (response, error) in
            if error == nil {
                Constant.appDelegate.hideProgressHUD()
                if let dict: NSDictionary = response as NSDictionary? {
                    let userData = UserDetail.init(dict as! [String: Any])
                    Storage.shared.saveUser(user: userData)
                    UserDefaults.loggedInUserId = userData.userId ?? ""
                    Alert().showAlertWithAction(title: "", message: "Data Updated Successfully", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                        vc.userLoginType = "Admin"
                        Storage.shared.saveStatus(type: vc.userLoginType)

                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)}, withCancelCallback: {})
                }
            } else {
                Constant.appDelegate.hideProgressHUD()
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
}
extension VerificationCodeVC: OTPFieldViewDelegate
{
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        self.hasEnteredOTP = hasEntered
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        if self.startEditing
        {
//            self.startEditing = false
            return true
        }
        else
        {
            self.startEditing = true
            return false
        }
    }
    
    func enteredOTP(otp otpString: String) {
        print("OTPString: \(otpString)")
        self.enteredOTP = otpString
    }
}

