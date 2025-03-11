//
//  ProfileSettingVC.swift
//  Phoneado
//
//  Created by Zimble on 4/7/22.
//

import UIKit
import SDWebImage
import ADCountryPicker

class ProfileSettingVC: UIViewController {
    //MARK: - View Life Cycle
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var countryDropDownView: UIView!
    @IBOutlet weak var editButton: UIButton!
    
    var selectedCountryDialCode = "+1"
    var makeEdit: Bool = false
    var imagePicker: ImagePicker!
    var imageUrl:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.type = "picture"
        self.setUpUI()
    }
    
    func setUpUI()
    {
        self.nameTextField.textColor = .black
        self.nameTextField.font = UIFont.appFontMedium(size: 14)
        
        self.numberTextField.textColor = .black
        self.numberTextField.font = UIFont.appFontMedium(size: 14)
        
        self.saveChangesButton.applyCorner()
        
        self.countryDropDownView.addGestureRecognizer(getTapGesture())
        
        self.setData()
        
        self.countryDropDownView.isUserInteractionEnabled = false
        self.numberTextField.isUserInteractionEnabled = false
        
    }
    
    func getTapGesture() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }

    func setData()
    {
        let user = Storage.shared.readUser()
        self.nameTextField.text = user?.fullName
        self.numberTextField.text = user?.mobile
        self.selectedCountryDialCode = user?.dialCode ?? ""
        self.profilePic.sd_setImage(with: URL(string: user?.profilePic ?? ""),placeholderImage: UIImage.init(named: "user"))
        self.dismiss(animated: true)
    }
    
    @objc func viewTapHandler(gesture: UITapGestureRecognizer)
    {
        let picker = ADCountryPicker(style: .grouped)
        picker.delegate = self
        picker.showCallingCodes = true
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true)
    }
    
    @IBAction func uploadImageAction(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func saveChangesClicked(_ sender: Any) {
        self.updateUser()
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "EditPhoneViewController") as! EditPhoneViewController
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUser()
    {
        var parm: [String: Any] = [:]
        
        parm.updateValue(self.nameTextField.text ?? "", forKey: "fullName")
        if imageUrl != nil{
            parm["profilePic"] = imageUrl
        }
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().updateUser(params: parm){ (response, error) in
            if error == nil
            {
                Constant.appDelegate.hideProgressHUD()
                if let dict: NSDictionary = response as NSDictionary?
                {
                    let userData = UserDetail.init(dict as! [String : Any])
                    Storage.shared.saveUser(user: userData)
                }
                Alert().showAlertWithAction(title: "Congratulations", message: "Your Data is updated successfully.", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {
                    self.setData()
                }, withCancelCallback: {})
            }else{
                Constant.appDelegate.hideProgressHUD()
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
    func callUploadMediaFileToServer(fileData: Data,image:UIImage?) {
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().uploadMultipleImages(images: [image!], imageParam : "image") { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            self.view.isUserInteractionEnabled = true
            if error == nil{
                if let data = response?["data"] as? Dictionary<String,Any>,let url = data["url"] as? String {
                    print("url", url)
                    self.imageUrl = url
                }
            }else{
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later.", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
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

extension ProfileSettingVC:ADCountryPickerDelegate {
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String) {
       
    }
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        picker.navigationController?.dismiss(animated: true, completion: nil)
        print("Selected Country Name = \(name),Selected Country Code = \(code),Selected Country Dial Code = \(dialCode)")
        if let flagImage = picker.getFlag(countryCode: code) {
            self.selectedCountryDialCode = dialCode
            self.countryImageView.image = flagImage
        }
    }
}
extension ProfileSettingVC: ImagePickerDelegate {
  func didSelect(image: UIImage?, data: Data?) {
      profilePic.image = image
    callUploadMediaFileToServer(fileData: data!, image: image)
  }
}
