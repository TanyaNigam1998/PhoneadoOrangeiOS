//
//  CreateGroupController.swift
//  TBHC Collaborate
//
//  Created by ZimTej on 2/5/21.
//  Copyright © 2021 ZimbleCode. All rights reserved.
//

import UIKit
import SVProgressHUD
class CreateGroupController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    var connectedUsers = [MobileList]()
    
    @IBOutlet weak var participantCOunt: UILabel!
    @IBOutlet weak var gImg: UIButton!
    @IBOutlet weak var groupNameTF: UITextField!
    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var groupImgString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        groupNameTF.delegate = self
        if connectedUsers.count > 0{
            self.participantCOunt.text = "(" + String(connectedUsers.count) + ")"
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 30
    }
    @IBAction func uploadGroupImg(_ sender: Any) {
        self.setupImagePicker(vc: self, completitionHandler: { (image) in
            self.gImg.setAttributedTitle(NSAttributedString(string: "", attributes: [NSAttributedString.Key : Any]()), for: .normal)
            self.groupImg.image = image
            self.uploadProfilePicServiceReuqest()
        }, docHandler: nil)
        
    }
    
    @IBAction func backActioin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func createGroupAction(_ sender: UIButton) {
        if groupNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Alert().showAlert(message: "Please enter group name")
        } else if connectedUsers.count == 0 {
            Alert().showAlert(message: "Please add participants to create group")
        } else {
            createGroupServiceRequest()
        }
    }
    @IBAction func removeMemberAction(_ sender: UIButton) {
        tableView.performBatchUpdates({
            self.tableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: .left)
             self.connectedUsers.remove(at: sender.tag)
        }) { (comp) in
            self.tableView.reloadData()
        }
        self.participantCOunt.text = "(" + String(connectedUsers.count) + ")"
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessagesCell
        cell.userName.text = connectedUsers[indexPath.row].fullName
        cell.userImg.sd_setImage(with: URL(string: connectedUsers[indexPath.row].profilePic ?? "" ),placeholderImage: #imageLiteral(resourceName: "user"))

        cell.removeBtn.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    //MARK:WebService
    func createGroupServiceRequest() {
        SVProgressHUD.show()
        var params = ["name":groupNameTF.text!,"members":connectedUsers.compactMap({$0.userId})] as [String : Any]
        if groupImgString != nil {
            params["image"] = groupImgString!
        }
        LoggedInRequest().createGroup(params: params) { (response, error) in
            SVProgressHUD.dismiss()
            if error == nil {
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popToViewController(ofClass: HomeVC.self)
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    func uploadProfilePicServiceReuqest() {
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        LoggedInRequest().uploadMultipleImages(images: [groupImg.image!]) { (response, error) in
             SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            if error == nil {
                if let data = response?["data"] as? Dictionary<String,Any>,let url = data["url"] as? String {
                    self.groupImgString = url
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
