//
//  SelectMembersController.swift
//  TBHC Collaborate
//
//  Created by ZimTej on 2/4/21.
//  Copyright © 2021 ZimbleCode. All rights reserved.
//

import UIKit
import SVProgressHUD
class SelectMembersController: BaseViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    var offset = 0
    var limit = 30
    var stopLoadMore = false
    var connectedUsers = [MobileList]()
    var selectedUsers = [MobileList]()
    var users = [MobileList]()
    var searchTimer: Timer?
    var groupId: String!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkRegisteredMobileRequest()
        if groupId != nil {
            nextBtn.setTitle("Add", for: .normal)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchTimer != nil {
            searchTimer?.invalidate()
            searchTimer = nil
        }
        if searchBar.text?.count != 0 {
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchForKeyword(_:)), userInfo: searchBar.text!, repeats: false)
        } else {
            connectedUsers = users
            tableView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    @objc func searchForKeyword(_ timer: Timer) {
        guard let keyword = timer.userInfo as? String else { return }
            connectedUsers = users.filter { user in
                if let fullName = user.fullName?.lowercased() {
                    return fullName.contains(keyword.lowercased())
                }
                return false
            }
            tableView.reloadData()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextAction(_ sender: Any) {
        if selectedUsers.count > 0 {
            if groupId != nil {
                editGroupServiceRequest()
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupController") as! CreateGroupController
                vc.connectedUsers = selectedUsers
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if groupId != nil {
                Alert().showAlert(message: "Please select/deselect members to add/remove them from group")
            } else {
                Alert().showAlert(message: "Please select member to create group")
            }
        }
    }
    //MARK:UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessagesCell
        cell.userName.text = connectedUsers[indexPath.row].fullName
        cell.userImg.sd_setImage(with: URL(string: connectedUsers[indexPath.row].profilePic ?? "" ),placeholderImage: UIImage(named:"user"))
        if selectedUsers.contains(where: {$0.userId == connectedUsers[indexPath.row].userId}) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if groupId != nil && selectedUsers.count > 30 {
            Alert().showAlert(message: "You can't add more than 30 members in a group")
            return
        }
        if selectedUsers.contains(where: {$0.userId == connectedUsers[indexPath.row].userId}) {
            if let index = selectedUsers.lastIndex(where: {$0.userId == connectedUsers[indexPath.row].userId}) {
                selectedUsers.remove(at: index)
            }
        } else {
            selectedUsers.append(connectedUsers[indexPath.row])
        }
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !stopLoadMore && indexPath.row == connectedUsers.count - 2 {
            offset=offset+1*limit
          
        }
    }
    
    func checkRegisteredMobileRequest(requestParams: [String: Any] = [:]) {
        self.view.endEditing(true)
        let contacts = AllContacts.map({
            var number = "+1"
            if ($0.mobile.contains("+")) {
                number = $0.mobile.keepNumbers
            } else {
                number = "+1\( $0.mobile.keepNumbers )"
            }
            if number.isEmpty {
                number = "+1"
            }
            return ["mobile": number]
        })
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().checkRegisteredMobileRequest(params: ["mobileList": contacts]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                do {
                    let responseData = try JSONDecoder().decode(CheckContactsModel.self, from: data)
                    let data = responseData.data.mobileList
                    self.users = data.filter { !$0.userId.isEmpty }
                    self.connectedUsers = self.users
                    self.tableView.reloadData()
                } catch let err {
                    print("Error = \(err.localizedDescription)")
                }
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }

    func editGroupServiceRequest() {
        SVProgressHUD.show()
        LoggedInRequest().editGroup(params: ["groupId":groupId!,"members":selectedUsers.compactMap({$0.userId})]) { (response, error) in
            SVProgressHUD.dismiss()
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
