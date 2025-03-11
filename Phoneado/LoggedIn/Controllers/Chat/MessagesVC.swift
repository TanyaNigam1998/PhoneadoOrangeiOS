//
//  MessagesVC.swift
//  Phoneado
//
//  Created by Zimble on 3/28/22.
//

import UIKit

class MessagesVC: UIViewController, UITextFieldDelegate {
    //MARK: - IB Outlets
    @IBOutlet weak var messagesTV: UITableView!
    @IBOutlet weak var messagesSearchBarView: UIView!
    @IBOutlet weak var searchBar: UITextField!
    //MARK: - Variable
    var getChatSummaryList:GetChatsData?
    var searchChat:GetChatsData?
    var userLoginType = ""
    var chatListCount = Int()
    var timer = Timer()
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetup()
        Socketton.shared.establishConnection()
        self.searchBar.delegate = self
        
    }
    
    //MARK: - Required Methods
    func initialViewSetup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(signinNotificationHandler(notificationInfo:)),
                                               name: Notification.Name.SigninNotification,
                                               object: nil)
        
        messagesSearchBarView.layer.cornerRadius = messagesSearchBarView.bounds.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounting), name: NSNotification.Name(rawValue: "reloadMessages"), object: nil)
        getChatRequest()
    }
    
    @objc func updateCounting() {
        print("counting...")
        self.view.endEditing(true)
        LoggedInRequest().getChatRequest(params: [:]) { (response, error) in
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                do {
                    let responseData = try? JSONDecoder().decode(GetChatsModel.self, from: data)
                    self.getChatSummaryList = responseData?.data
                    self.chatListCount = self.getChatSummaryList?.chatSummaryList.count ?? 0
                    self.searchBar.placeholder = "\(self.chatListCount) chats"
                    self.messagesTV.reloadData()
                } catch let err {
                    print("Err", err.localizedDescription)
                }
                self.searchChat = self.getChatSummaryList
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                print("Error = \(error?.message ?? TextString.inValidResponseError)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func timeStringFromUnixTime(unixTime: Double) -> String {
        let dateVal = TimeInterval(unixTime)
        
        let date = Date(timeIntervalSince1970: TimeInterval(dateVal))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        // Returns date formatted as 12 hour time.
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date as Date)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            self.getChatSummaryList?.chatSummaryList = (self.searchChat?.chatSummaryList.filter({
                if $0.senderId != Storage.shared.getUserId()!{
                    return ($0.senderFullName ?? "").lowercased().contains( updatedText.lowercased()) || ($0.groupName ?? "").lowercased().contains( updatedText.lowercased())
                }else{
                    return ($0.receiverFullName ?? "").lowercased().contains( updatedText.lowercased()) || ($0.groupName ?? "").lowercased().contains( updatedText.lowercased())
                }
                
            }))!
            if (updatedText == "") {
                self.getChatSummaryList = self.searchChat
            }
            self.messagesTV.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func createGroupAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectMembersController") as! SelectMembersController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func sideMenuTapped(_ sender: Any) {
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
        vc.userLoginType = self.userLoginType
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    @objc func signinNotificationHandler(notificationInfo:Notification) {
        if let userInfo = notificationInfo.userInfo as? [String:Any] {
            if let userLoginType = userInfo["UserLoginType"] as? String {
                print("User Login Type = \(userLoginType)")
            }
        }
    }
    func tableViewSetup() {
        messagesTV.delegate = self
        messagesTV.dataSource = self
        messagesTV.register(UINib(nibName: "HomeContactsTVHeaderCell", bundle: nil), forCellReuseIdentifier: "HomeContactsTVHeaderCell")
        messagesTV.register(UINib(nibName: "MessagesTVC", bundle: nil), forCellReuseIdentifier: "MessagesTVC")
        initialViewSetup()
    }
}
extension MessagesVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Chat count = \(self.getChatSummaryList?.chatSummaryList.count ?? 0)")
        return self.getChatSummaryList?.chatSummaryList.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTV.dequeueReusableCell(withIdentifier: "MessagesTVC") as! MessagesTVC
        cell.selectionStyle = .none
        let user: UserDetail = Storage().readUser()!
        if let userId = user.userId {
            print("UserId = \(userId)")
            if let senderId = self.getChatSummaryList?.chatSummaryList[indexPath.row].senderId {
                if senderId == userId {
                    cell.isReadVIew.isHidden = true
                    if self.getChatSummaryList?.chatSummaryList[indexPath.row].type == "image" {
                        cell.contactMessageLbl.text = "You: Image"
                    } else {
                        cell.contactMessageLbl.text = "You: \(self.getChatSummaryList?.chatSummaryList[indexPath.row].message ?? "")"
                    }
                    cell.contactNameLbl.text = self.getChatSummaryList?.chatSummaryList[indexPath.row].receiverFullName ?? ""
                    let time = self.timeStringFromUnixTime(unixTime: Double(self.getChatSummaryList?.chatSummaryList[indexPath.row].sentAt ?? 0))
                    cell.messageTimeLbl.text = "\(time)"
                    cell.contactImgView.sd_setImage(with: URL(string: getChatSummaryList?.chatSummaryList[indexPath.row].receiverProfilePic ?? ""),placeholderImage: UIImage(named: "user"))
                } else {
                    cell.isReadVIew.isHidden = false
                    cell.countLbl.text = "\(self.getChatSummaryList?.chatSummaryList[indexPath.row].unReadCount ?? 0)"
                    
                    if self.getChatSummaryList?.chatSummaryList[indexPath.row].isRead == true {
                        cell.isReadVIew.backgroundColor = UIColor.gray
                        cell.isReadVIew.isHidden = true
                    } else {
                        cell.isReadVIew.backgroundColor = UIColor.appOrangeColor
                        cell.isReadVIew.isHidden = false
                    }
                    cell.isReadVIew.isHidden = (self.getChatSummaryList?.chatSummaryList[indexPath.row].unReadCount ?? 0) == 0
                    cell.isReadVIew.applyCorner()
                    if self.getChatSummaryList?.chatSummaryList[indexPath.row].type == "image"
                    {
                        cell.contactMessageLbl.text = "You: Image"
                    } else {
                        cell.contactMessageLbl.text = "To: \(self.getChatSummaryList?.chatSummaryList[indexPath.row].message ?? "")"
                    }
                    cell.contactNameLbl.text = self.getChatSummaryList?.chatSummaryList[indexPath.row].senderFullName ?? ""
                    let time = self.timeStringFromUnixTime(unixTime: Double(self.getChatSummaryList?.chatSummaryList[indexPath.row].sentAt ?? 0))
                    cell.messageTimeLbl.text = "\(time)"
                    cell.contactImgView.sd_setImage(with: URL(string: getChatSummaryList?.chatSummaryList[indexPath.row].senderProfilePic ?? ""),placeholderImage: UIImage(named: "user"))
                }
            }
            if self.getChatSummaryList?.chatSummaryList[indexPath.row].groupId != nil {
                cell.contactNameLbl.text = getChatSummaryList?.chatSummaryList[indexPath.row].groupName
                cell.contactImgView.sd_setImage(with: URL(string: getChatSummaryList?.chatSummaryList[indexPath.row].groupImage ?? ""),placeholderImage: UIImage(named: "Group"))
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = messagesTV.cellForRow(at: indexPath) as! MessagesTVC
        let vc = UIStoryboard(name: StoryBoardName.loggedIn.rawValue, bundle: nil).instantiateViewController(withIdentifier: "IndividualChatDetailVC") as! IndividualChatDetailVC
        vc.individualName = cell.contactNameLbl.text?.capitalized ?? ""//self.getChatSummaryList?.chatSummaryList[indexPath.row].receiverFullName ?? ""
        vc.groupId = self.getChatSummaryList?.chatSummaryList[indexPath.row].groupId
        vc.messageDetail = self.getChatSummaryList?.chatSummaryList[indexPath.row]
        vc.isMemberExists = self.getChatSummaryList?.chatSummaryList[indexPath.row].isMemberExists ?? true
        let user: UserDetail = Storage().readUser()!
        
        if let userId = user.userId {
            print("UserId = \(userId)")
            if let senderId = self.getChatSummaryList?.chatSummaryList[indexPath.row].senderId {
                if senderId == userId {
                    vc.toID = self.getChatSummaryList?.chatSummaryList[indexPath.row].receiverId ?? ""
                } else {
                    vc.toID = self.getChatSummaryList?.chatSummaryList[indexPath.row].senderId ?? ""
                }
            }
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
}
extension MessagesVC {
    func getChatRequest(requestParams:[String:Any] = [:]) {
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getChatRequest(params: [:]) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                do {
                    let responseData = try? JSONDecoder().decode(GetChatsModel.self, from: data)
                    self.getChatSummaryList = responseData?.data
                    self.chatListCount = self.getChatSummaryList?.chatSummaryList.count ?? 0
                    self.searchBar.placeholder = "\(self.chatListCount) chats"
                    self.messagesTV.reloadData()
                } catch let err {
                    print("Err", err.localizedDescription)
                }
                self.searchChat = self.getChatSummaryList
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
                print("Error = \(error?.message ?? TextString.inValidResponseError)")
            }
        }
    }
}
