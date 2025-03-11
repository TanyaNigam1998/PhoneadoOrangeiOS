//
//  GroupDetailController.swift
//  TBHC Collaborate
//
//  Created by ZimTej on 2/15/21.
//  Copyright © 2021 ZimbleCode. All rights reserved.
//

import UIKit
import SVProgressHUD
class GroupDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var addMoreBtn: UIButton!
    @IBOutlet weak var deleteGroupBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var groupImg: UIImageView!
    var groupId: String!
    var groupMembers = [MobileList]()
    var detail: GroupDetail!
    var isMemberExists = true

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        self.tableView.isHidden = true
        editBtn.isHidden  = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.getGroupDetailServiceRequest()
    }

    func showGroupDetail() {
        if detail != nil {
            groupTitle.text = detail.name
            groupImg.sd_setImage(with: URL(string: detail.image ?? ""))
            if detail.admin != Storage.shared.getUserId() {
                deleteGroupBtn.setTitle("Exit Group", for: .normal)
                addMoreBtn.isHidden = true
            }
            if detail.totalMembers ?? 0 > 0{
                countLbl.text = "(" + String(detail.totalMembers ?? 0) + ")"
            }else{
                countLbl.text = ""
            }
        }
        
    }

    @IBAction func deleteGroupAction(_ sender: Any) {
        if detail.admin == Storage.shared.getUserId(){
            Alert().showAlertWithAction(title: "Delete Group", message: "Are you sure you want to delete this group?", buttonStyle: .destructive, withVC:self , buttonTitle: "Delete", secondBtnTitle:"Cancel") {
                self.deleteGroupServiceRequest()
            } withCancelCallback: {}

        }else{
            Alert().showAlertWithAction(title: "Leave Group", message: "Are you sure you want to Leave this group?", buttonStyle: .destructive, withVC:self , buttonTitle: "Leave", secondBtnTitle:"Cancel") {
                self.deleteMemberFromGroupServiceRequest()
            } withCancelCallback: {}
        }
        
    }
    @IBAction func removeMemberAction(_ sender: UIButton) {
        Alert().showAlertWithAction(title: "Remove Participant", message: "Are you sure you want to remove this participant?", buttonStyle: .destructive, withVC:self , buttonTitle: "Remove", secondBtnTitle:"Cancel") {
            self.deleteMemberFromGroupServiceRequest(uId: self.groupMembers[sender.tag].userId , index: sender.tag)
        } withCancelCallback: {}
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addMoreAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectMembersController") as! SelectMembersController
        vc.groupId = groupId
        vc.selectedUsers = groupMembers
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func editAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditGroupController") as! EditGroupController
        vc.groupId = groupId
        vc.detail = detail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK:UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessagesCell
        cell.userName.text = groupMembers[indexPath.row].fullName
        cell.userImg.sd_setImage(with: URL(string: groupMembers[indexPath.row].profilePic ?? "" ),placeholderImage: #imageLiteral(resourceName: "user"))
        if let det = detail, det.admin == Storage.shared.getUserId(){
            cell.removeBtn.isHidden = false
        }else{
            cell.removeBtn.isHidden = true
        }
        if groupMembers[indexPath.row].isAdmin ?? false{
            cell.removeBtn.isHidden = false
            cell.removeWidth.constant = 60
            cell.removeBtn.setTitle("Admin", for: .normal)
            cell.removeBtn.setTitleColor(.orange, for: .normal)
            cell.removeBtn.isEnabled = false
            cell.removeBtn.setImage(nil, for: .normal)

        }else{
            cell.removeWidth.constant = 35
//            cell.removeBtn.setImage(#imageLiteral(resourceName: "ic_delete_account"), for: .normal)
            cell.removeBtn.setTitle("x", for: .normal)
            cell.removeBtn.isEnabled = true
        }
        cell.removeBtn.setTitleColor(.gray, for: .normal)

        cell.removeBtn.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      /*  if groupMembers[indexPath.row].userId != Storage.shared.getUserId(){
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "IndividualChatDetailVC") as! IndividualChatDetailVC
            chatVC.toID = groupMembers[indexPath.row].userId
            chatVC.toName = groupMembers[indexPath.row].fullName
            chatVC.toImg = groupMembers[indexPath.row].profilePic
            chatVC.individualName = groupMembers[indexPath.row].fullName ?? ""
            self.navigationController?.pushViewController(chatVC, animated: true)
        } */
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    //MARK:WEBService
    func getGroupDetailServiceRequest(){
      
        LoggedInRequest().groupDetail(groupId: groupId ?? "") { (response, gDetail, error) in
            SVProgressHUD.dismiss()
            if error == nil{
                self.detail = gDetail
                let data = response!.map({$0.toDictionary()})
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                guard let data2 = jsonData else { return }
                do {
                    let responseData = try? JSONDecoder().decode([MobileList].self, from: data2)
                    self.groupMembers = responseData!
                   
                } catch let err {
                    print("Err", err.localizedDescription)
                }
                self.tableView.isHidden = false
                if self.isMemberExists {
                    self.editBtn.isHidden = false
                } else {
                    self.editBtn.isHidden = true
                }
                self.showGroupDetail()
                self.tableView.reloadData()
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    func deleteMemberFromGroupServiceRequest(uId:String = "",index:Int = 0) {
        SVProgressHUD.show()
        let params = [String:Any]()
        var usrId = groupId ?? ""
        if !uId.isEmpty{
            usrId = groupId + "?userId=\(uId)"
//            params["userId"] = uId
        }
        LoggedInRequest().leaveGroup(groupId: usrId, params: params) { (response, error) in
            SVProgressHUD.dismiss()
            if error == nil{
                if !uId.isEmpty{
                    self.tableView.performBatchUpdates({
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
                        self.groupMembers.remove(at: index)
                    }) { (comp) in
                        self.tableView.reloadData()
                    }
                }else{
                    self.navigationController?.popToViewController(ofClass: HomeVC.self)
                }
            }else{
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
    func deleteGroupServiceRequest(){
        SVProgressHUD.show()
        LoggedInRequest().deleteGroup(id: groupId) { (response, error) in
            SVProgressHUD.dismiss()
            if error == nil{
                self.navigationController?.popToViewController(ofClass: HomeVC.self)
            }else{
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}
