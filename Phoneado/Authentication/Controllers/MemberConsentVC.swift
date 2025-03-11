//
//  MemberConsentVC.swift
//  Phoneado
//
//  Created by Zimble on 3/24/22.
//

import UIKit

class MemberConsentVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var termsAndConditionLbl: UILabel!
    @IBOutlet weak var termsAndConditionsCheckImgView: UIImageView!
    @IBOutlet weak var termsAndConditionsCheckView: UIView!
    @IBOutlet weak var termsAndConditionsCheckBtn: UIButton!
    @IBOutlet weak var consentBtnGradientView: GradientView!
    @IBOutlet weak var consentWebView: UIWebView!
    
    //MARK: - Variable
    var buttonState = "notChecked"
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        // Do any additional setup after loading the view.
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: termsAndConditionLbl.text ?? "")
        attributedString.setColorForText(textForAttribute: "Terms & Conditions", withColor: UIColor(named: "AppColor") ?? UIColor.black)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSMakeRange(20,18))
        termsAndConditionLbl.attributedText = attributedString
        consentBtnGradientView.gradientLayer.cornerRadius = consentBtnGradientView.bounds.height / 2
        consentBtnGradientView.layer.cornerRadius = consentBtnGradientView.bounds.height / 2
        
        guard let file = Bundle.main.path(forResource: "privacy", ofType: "html"),
               let html = try? String(contentsOfFile: file, encoding: String.Encoding.utf8)
           else {
               return
           }
        consentWebView.loadHTMLString(html, baseURL: nil)
        
        
//        let url = URL (string: "https://drive.google.com/viewerng/viewer?embedded=true&url=https://phoneadodata.s3.us-east-2.amazonaws.com/Phoneado_Privacy_PolicyV1.1.pdf")
//        let requestObj = URLRequest(url: url!)
//        consentWebView.loadRequest(requestObj)
    }

    //MARK: - IB Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func termsAndConditionsCheckTapped(_ sender: Any) {
            if(buttonState == "notChecked") {
                termsAndConditionsCheckImgView.image = UIImage(named: "checkOrange")
                termsAndConditionsCheckImgView.backgroundColor = .white
                buttonState = "checked"
            }
            else {
                termsAndConditionsCheckImgView.image = UIImage(named: "")
                termsAndConditionsCheckImgView.backgroundColor = UIColor(named: "DarkGrayTextColor")
                buttonState = "notChecked"
            }
    }
    @IBAction func termsAndConditionsBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "TermsAndConditionsVC") as! TermsAndConditionsVC
        vc.isViaSignup = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func consentBtnTapped(_ sender: Any) {
        if buttonState == "notChecked" {
            self.show(message: TaostMessages.consentUnchecked, controller: self)
        }else {
            let userFullName = UserDefaults.standard.string(forKey: UserDefault.signUpUserName) ?? ""
            let mobileNumber = UserDefaults.standard.string(forKey: UserDefault.signUpMobileNumber) ?? ""
            let otpToken = UserDefaults.standard.string(forKey: UserDefault.verifyOTPToken) ?? ""
            let password = UserDefaults.standard.string(forKey: UserDefault.enteredConfirmPin ) ?? ""
            let pic = UserDefaults.standard.string(forKey: UserDefault.profilePic)
            var requestDict = ["deviceToken": SaveToken.deviceToken!,
                                   "fullName":userFullName,
                                   "mobile":mobileNumber,
                               "otpToken":Int(otpToken) ?? 0,
                                   "password":password,
                               "userType":"app"] as [String : Any]
            if pic != nil{
                requestDict["profilePic"] = pic
            }
                print("Sign Up Request Dict = \(requestDict)")
            userSignUpRequest(requestParams: requestDict)
        }
    }
}
extension MemberConsentVC {
    func userSignUpRequest(requestParams:[String:Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().signup(params: requestParams) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                print("response = \(response ?? [:])")
                Storage.shared.saveUser(user: UserDetail(response!))

                let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.userLoginType = "Admin"
                Storage.shared.saveStatus(type: vc.userLoginType)
                Storage.shared.savephoneNumberr(type:(response as! NSDictionary).value(forKey: "mobile") as! String)

                vc.isViaSignup = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
