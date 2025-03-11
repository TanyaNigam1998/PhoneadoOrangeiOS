//
//  ForgotPinVC.swift
//  Phoneado
//
//  Created by Zimble on 3/24/22.
//

import UIKit
import ADCountryPicker

class ForgotPinVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var signInGradientView: GradientView!
    @IBOutlet weak var selectedCountryImgView: UIImageView!
    @IBOutlet weak var countinueBtn: UIButton!
    @IBOutlet weak var enterNumberLbl: UITextField!
    
    var selectedCountryDialCode = "+1"
    var userMobileNumber: String = ""
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        // Do any additional setup after loading the view.
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        outerView.layer.cornerRadius = 30
        signInGradientView.gradientLayer.cornerRadius = signInGradientView.bounds.height / 2
        signInGradientView.layer.cornerRadius = signInGradientView.bounds.height / 2
        outerView.applyDropShadowShadow()
//        outerView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.15), opacity: 1, offSet:CGSize(width: -1, height: 1), radius: 30, scale: false)
    }
    //MARK: - IB Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func selectCountryTapped(_ sender: Any) {
        let picker = ADCountryPicker(style: .grouped)
        picker.delegate = self
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
    }
    @IBAction func continueBtnTapped(_ sender: Any) {
        guard let number = self.enterNumberLbl.text else {
            return
        }
        if number.isEmpty
        {
            Alert().showAlert(message: TextMessages.emptyEmail)
            return
        }
        self.view.endEditing(true)
        self.userMobileNumber = "\(selectedCountryDialCode)\(enterNumberLbl.text ?? "")"
        let requestDict = ["mobile": self.userMobileNumber ,
                           "type": OtpType.FORGOT_OTP]
        
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().createOTP(params: requestDict) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                self.enterNumberLbl.text = ""
                let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
                vc.phoneNumber = self.userMobileNumber
                vc.fromForgotVC = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                    Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
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
extension ForgotPinVC:ADCountryPickerDelegate {
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        self.dismiss(animated: true, completion: nil)
        if let flagImage = picker.getFlag(countryCode: code)
        {
            self.selectedCountryDialCode = dialCode
            self.selectedCountryImgView.image = flagImage
        }
    }
}
