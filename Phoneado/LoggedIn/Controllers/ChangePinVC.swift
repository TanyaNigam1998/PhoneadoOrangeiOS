//
//  ChangePinVC.swift
//  Phoneado
//
//  Created by Zimble on 4/7/22.
//

import UIKit
import SVPinView
import OTPFieldView

class ChangePinVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backButton: UIView!
    @IBOutlet weak var eyeToggleButton: UIButton!
    @IBOutlet weak var enteredPinTextField: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
    
    var startEditing: Bool = false

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enteredPinTextField.delegate = self
        self.configurePinView()
        // Do any additional setup after loading the view.
    }
    
    func configurePinView() {
//        pinView.pinLength = 4
//        pinView.secureCharacter = "\u{25CF}"
//        pinView.interSpace = 10
//        pinView.textColor = UIColor.black
//        pinView.borderLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
//        pinView.activeBorderLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
//        pinView.borderLineThickness = 1
//        pinView.shouldSecureText = true
//        pinView.allowsWhitespaces = false
//        pinView.style = .none
//        pinView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
//        pinView.activeFieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
//        pinView.fieldCornerRadius = 15
//        pinView.activeFieldCornerRadius = 15
//        pinView.placeholder = ""
//        pinView.deleteButtonAction = .deleteCurrentAndMoveToPrevious
//        pinView.keyboardAppearance = .default
//        pinView.tintColor = .white
//        pinView.becomeFirstResponderAtIndex = 4
//        pinView.shouldDismissKeyboardOnEmptyFirstField = true
//        pinView.font = UIFont.systemFont(ofSize: 15)
//        pinView.keyboardType = .phonePad
//        pinView.pinInputAccessoryView = { () -> UIView in
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
//        pinView.didFinishCallback = didFinishEnteringPin(pin:)
//        pinView.didChangeCallback = { pin in
//            print("The entered pin is \(pin)")
//            self.userPassword = pin
//        }
//        pinView.activeBorderLineThickness = 1
//        pinView.fieldBackgroundColor = UIColor.clear
//        pinView.activeFieldBackgroundColor = UIColor.clear
//        pinView.fieldCornerRadius = 0
//        pinView.activeFieldCornerRadius = 0
//        pinView.style = .underline


        self.enteredPinTextField.isSecureTextEntry = true
    }
    
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.enteredPinTextField {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        self.verifyPassword()
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func eyeButtonTapped(_ sender: Any) {
        self.eyeToggleButton.isSelected = !self.eyeToggleButton.isSelected
        self.enteredPinTextField.isSecureTextEntry = !self.enteredPinTextField.isSecureTextEntry
    }
    
    func verifyPassword()
    {
        if self.enteredPinTextField.text?.count ?? 0 < 4 {
            self.show(message:TaostMessages.invalidPinEntered, controller:self)
            return
        }
        var parm: [String:Any] = [:]
        parm.updateValue(self.enteredPinTextField.text ?? "", forKey: "password")
        
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().verifyPin(params: parm) {(response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil
            {
                let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SignUpPinVC") as! SignUpPinVC
                vc.fromChangePinVC = true
                vc.oldPassword = self.enteredPinTextField.text ?? ""
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else{
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
    
//    func changePin()
//    {
//        var parm: [String:Any] = [:]
//        parm.updateValue(self.userPassword, forKey: "password")
//        Constant.appDelegate.showProgressHUD(view: self.view)
//        LoggedInRequest().changePin(params: parm) {(response, error) in
//            Constant.appDelegate.hideProgressHUD()
//            if error == nil
//            {
//                Alert().showAlert(message: "Yuppiieeee")
//            }else{
//                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
//            }
//        }
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

