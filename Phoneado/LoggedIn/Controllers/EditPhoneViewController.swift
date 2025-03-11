//
//  EditPhoneViewController.swift
//  Phoneado
//
//  Created by Apple on 26/05/22.
//

import UIKit
import ADCountryPicker

class EditPhoneViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var countryImageVIew: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var cancelButton: CustomButtonRegular!
    {
        didSet{
            cancelButton.isGradiantLayerEnable = true
            cancelButton.applyCorner()
            cancelButton.titleLabel?.font = UIFont.appFontMedium(size: 12)
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(.white, for: .normal)
        }
    }
    @IBOutlet weak var confirmButton: CustomButtonRegular!
    {
        didSet{
            confirmButton.isGradiantLayerEnable = true
            confirmButton.applyCorner()
            confirmButton.titleLabel?.font = UIFont.appFontMedium(size: 12)
            confirmButton.setTitle("Confirm", for: .normal)
            confirmButton.setTitleColor(.white, for: .normal)
        }
    }
    
    var selectedCountryDialCode = "+1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        self.numberTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func setUpUI()
    {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let user = Storage.shared.readUser()
        self.numberTextField.text = user?.mobile
        
        self.backView.applyCorner(10)
        self.cancelButton.applyCorner()
        self.confirmButton.applyCorner()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == self.numberTextField{
            let maxLength = 15
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func confirmAction(_ sender: Any) {
        self.createOTP()
    }
    @IBAction func selectCountryTapped(_ sender: Any) {
        let picker = ADCountryPicker(style: .grouped)
        picker.delegate = self
        picker.showCallingCodes = true
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true)
    }
    
    func createOTP()
    {
        if self.numberTextField.text?.count ?? 0 < 10
        {
            self.show(message: "Please Enter valid phone number", controller: self)
        }else{
            let number: String = self.numberTextField.text ?? ""
            let params = ["mobile":number, "type":"UU"]
            Constant.appDelegate.showProgressHUD(view: self.view)
            LoggedInRequest().createOTP(params: params) { (response, error) in
                Constant.appDelegate.hideProgressHUD()
                if error == nil
                {
                    let vc = UIStoryboard(name: StoryBoardName.authentication.rawValue, bundle: nil).instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
                    vc.phoneNumber = number
                    vc.fromEditPhoneController = true
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else
                {
                    if error?.code != 1 {
                        Alert().showAlert(message: error?.message ?? "Something went wrong please try again later")
                    }
                }
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

extension EditPhoneViewController:ADCountryPickerDelegate {
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String) {
       
    }
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        picker.navigationController?.dismiss(animated: true, completion: nil)
        print("Selected Country Name = \(name),Selected Country Code = \(code),Selected Country Dial Code = \(dialCode)")
        if let flagImage = picker.getFlag(countryCode: code) {
            self.selectedCountryDialCode = dialCode
            countryImageVIew.image = flagImage
        }
    }
}
