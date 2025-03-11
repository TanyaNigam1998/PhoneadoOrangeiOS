
import UIKit
import SVPinView

class SignUpPinVC: UIViewController, UITextFieldDelegate {
    //MARK: - IB Outlets
 
    @IBOutlet weak var continueBtnGradientView: GradientView!
    @IBOutlet weak var newPinEyeButton: UIButton!
    
    @IBOutlet weak var confirmPinfield: UITextField!
    @IBOutlet weak var newPinfield: UITextField!
    @IBOutlet weak var confirmPinEyeButton: UIButton!
    //MARK: - Variable
    var enterNewPinHideUnhideIsSelected = false
    var confirmPinHideUnhideIsSelected = false
    var fromChangePinVC: Bool = false
    var fromForgotVC: Bool = false
    var oTpToken: Int?
    var mobile: String = ""
    var oldPassword: String = ""
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        // Do any additional setup after loading the view.
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        confirmPinfield.delegate = self
        newPinfield.delegate = self
        configurePinView()
        continueBtnGradientView.gradientLayer.cornerRadius = continueBtnGradientView.bounds.height / 2
        continueBtnGradientView.layer.cornerRadius = continueBtnGradientView.bounds.height / 2
    }
    func configurePinView() {
        confirmPinfield.isSecureTextEntry = true
        newPinfield.isSecureTextEntry = true
        
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.confirmPinfield || textField == self.newPinfield {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
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
    @IBAction func newPinEyebtnTapped(_ sender: Any) {
        self.newPinEyeButton.isSelected = !self.newPinEyeButton.isSelected
        self.newPinfield.isSecureTextEntry = !self.newPinfield.isSecureTextEntry
    }
    @IBAction func confirmPinEyebtnTapped(_ sender: Any) {
        self.confirmPinEyeButton.isSelected = !self.confirmPinEyeButton.isSelected
        self.confirmPinfield.isSecureTextEntry = !self.confirmPinfield.isSecureTextEntry
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        if fromChangePinVC
        {
            self.dismiss(animated: true, completion: nil)
        }else if fromForgotVC{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func continueBtnTapped(_ sender: Any) {
        if newPinfield.text?.count ?? 0 < 4 {
            self.show(message:TaostMessages.invalidPinEntered, controller:self)
        }else if confirmPinfield.text?.count ?? 0 < 4 {
            self.show(message: TaostMessages.confirmPinEntered, controller: self)
        }else if newPinfield.text != confirmPinfield.text {
            self.show(message: TaostMessages.enteredPinMismatch, controller: self)
        }else {
            let enteredConfirmPin = Int(confirmPinfield.text ?? "")
            UserDefaults.standard.set(enteredConfirmPin, forKey: UserDefault.enteredConfirmPin)
            print("Entered Confirm Pin = \(UserDefaults.standard.string(forKey: UserDefault.enteredConfirmPin ) ?? "")")
            if fromChangePinVC
            {
                var param: [String:Any] = [:]
                param.updateValue(self.oldPassword, forKey: "oldPassword")
                param.updateValue(self.confirmPinfield.text ?? "", forKey: "newPassword")
                Constant.appDelegate.showProgressHUD(view: self.view)
                AuthenticationRequest().changePassword(params: param) {(response, error) in
                    Constant.appDelegate.hideProgressHUD()
                    if error == nil{
                        Alert().showAlertWithAction(title: "Congratulations", message: "Your pin is changed successfully", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }, withCancelCallback: {})
                    }else{
                        Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
                    }
                }
            }else if fromForgotVC{
                var param: [String:Any] = [:]
                param.updateValue(String(self.oTpToken ?? 0), forKey: "otpToken")
                param.updateValue(self.confirmPinfield.text, forKey: "newPassword")
                param.updateValue(self.mobile, forKey: "mobile")
                Constant.appDelegate.showProgressHUD(view: self.view)
                AuthenticationRequest().forgotPassword(params: param) {(response, error) in
                    Constant.appDelegate.hideProgressHUD()
                    if error == nil{
                        Alert().showAlertWithAction(title: "Congratulations", message: "Your pin is changed successfully", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {
                            Constant.sceneDelegate?.openSignUpVC()
                        }, withCancelCallback: {})
                    }else{
                        Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
                    }
                }
            }else{
                let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "MemberConsentVC") as! MemberConsentVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
