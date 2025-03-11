//
//  EditGroupController.swift
//  TBHC Collaborate
//
//  Created by ZimTej on 2/15/21.
//  Copyright © 2021 ZimbleCode. All rights reserved.
//

import UIKit
import SVProgressHUD
class EditGroupController: BaseViewController,UITextFieldDelegate {

    @IBOutlet weak var groupNamrTF: UITextField!
    @IBOutlet weak var groupImg: UIImageView!
    var groupId:String!
    var groupImgString:String!
    var detail:GroupDetail!
    var isMemberExists = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if detail != nil{
            groupImg.sd_setImage(with: URL(string: detail.image ?? ""))
            groupNamrTF.text  = detail.name
            groupNamrTF.becomeFirstResponder()
        }
        groupNamrTF.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 30
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func saveAction(_ sender: Any) {
        if groupNamrTF.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            Alert().showAlert(message: "Please enter group name")
        }else{
            editGroupServiceRequest()
        }
    }
    @IBAction func changeGroupImg(_ sender: Any) {
        self.setupImagePicker(vc: self, completitionHandler: { (image) in
            self.groupImg.image = image
            self.uploadProfilePicServiceReuqest()
        }, docHandler: nil)
    }
    func editGroupServiceRequest(){
        SVProgressHUD.show()
        var params = ["groupId":groupId!,"name":groupNamrTF.text!]
        if groupImgString != nil{
            params["image"] = groupImgString
        }
        LoggedInRequest().editGroup(params:params ) { (response, error) in
            SVProgressHUD.dismiss()
            if error == nil{
                NotificationCenter.default.post(name: Notification.Name(HObservers.updateGroupNameImage), object: nil, userInfo: params)
                self.navigationController?.popViewController(animated: true)
            }else{
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    func uploadProfilePicServiceReuqest(){
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        LoggedInRequest().uploadMultipleImages(images: [groupImg.image!]) { (response, error) in
             SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            if error == nil{
                if let data = response?["data"] as? Dictionary<String,Any>,let url = data["url"] as? String {
                    self.groupImgString = url
                }
            }else{
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
