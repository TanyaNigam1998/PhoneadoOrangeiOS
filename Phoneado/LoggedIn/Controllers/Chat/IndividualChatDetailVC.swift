//
//  IndividualChatDetailVC.swift
//  Phoneado
//
//  Created by Zimble on 4/20/22.
//

enum MessageType {
    case text
    case image
    case display
    func type() -> String {
        switch self {
        case .text:
            return "text"
        case .image:
            return "image"
        case .display:
            return "display"
        }
    }
}
enum GroupChatActions {
    case removed
    case left
    case imageChange
    case nameChange
    case groupCreated
    case addMember
    func type(actionon:ChatActions?,actionby:ChatActions?) -> String {
        switch self {
        case .removed:
            if actionby?.userId == Storage.shared.getUserId() {
                return "You removed \(actionon?.fullName ?? "") "
            } else if actionon?.userId == Storage.shared.getUserId() {
                return "\(actionby?.fullName ?? "") removed you"
            } else {
                return "\(actionby?.fullName ?? "") removed \(actionon?.fullName ?? "")"
            }
        case .imageChange:
            if actionby?.userId == Storage.shared.getUserId() {
                return "You changed this group's icon"
            } else {
                return "\(actionby?.fullName ?? "") changed this group's icon"
            }
        case .nameChange:
            if actionby?.userId == Storage.shared.getUserId() {
                return "You changed the group name to \(actionby?.groupName ?? "")"
            } else {
                return "\(actionby?.fullName ?? "") changed the group name to \(actionby?.groupName ?? "")"
            }
        case .left:
            return "\(actionon?.fullName ?? "") left"
        case .groupCreated:
            if actionby?.userId == Storage.shared.getUserId() {
                return "You created group \(actionby?.groupName ?? "") "
            } else {
                return "\(actionby?.fullName ?? "") created group \(actionby?.groupName ?? "")"
            }
        case .addMember:
            if actionby?.userId == Storage.shared.getUserId() {
                return "You added \(actionon?.fullName ?? "") "
            } else if actionon?.userId == Storage.shared.getUserId() {
                return "\(actionby?.fullName ?? "") added you"
            } else {
                return "\(actionby?.fullName ?? "") added \(actionon?.fullName ?? "")"
            }
        }
    }
}
var currentChatUserId: String!

import UIKit
import IQKeyboardManager
import SDWebImage

class IndividualChatDetailVC: UIViewController, UITextFieldDelegate {
    //MARK: - IB Outlets
    @IBOutlet weak var individualNameLbl: UILabel!
    @IBOutlet weak var chatTV: UITableView! {
        didSet {
            chatTV.delegate = self
            chatTV.dataSource = self
        }
    }
    
    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var noMemberView: UIView!
    @IBOutlet weak var groupInfoBtn: UIButton!
    @IBOutlet weak var typeMessageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messsageTF: UITextField!
    @IBOutlet weak var messageTFBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    //MARK: - Variable
    var individualName = ""
    var messageDetail:ChatSummaryList!
    var fromRequests = false
    var messages = [ChatData]()
    var toID:String!
    var toImg:String!
    var toName:String!
    var profilePic:String!
    var chatUserDetail:ChatUser!
    var getUserChatDetailData:GetUserChatDetailData?
    var completitionClosure: ((UIImage, String) -> Void)?
    var completition: ((UIEdgeInsets) -> Void)?
    var imagePicker: ImagePicker!
    var isViaDetail:Bool = Bool()
    var isLoadMore:Bool = false
    var totalCount: Int = 0
    var addedMessageCount = [ChatData]()
    var groupId:String!
    var isMemberExists = true
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        messsageTF.setLeftPaddingPoints(10)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.type = "picture"
        if groupId != nil {
            groupInfoBtn.isHidden = false
            Socketton.shared.subscribeGroupChannel(groupId: groupId, userId: Storage.shared.getUserId() ?? "")
            groupImg.sd_setImage(with: URL(string: messageDetail.groupImage ?? ""),placeholderImage: UIImage.init(named: "Group"))
        } else {
            groupImg.isHidden = true
        }
        self.showHideExistanceInGroup()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateGroupDetail(notification:)), name: Notification.Name(HObservers.updateGroupNameImage), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentChatUserId = toID
        toName = individualName
                IQKeyboardManager.shared().isEnabled = false
        self.isMessageReceived()
        self.isGroupMessageReceived()
        self.isErrorRecievedWhileSendingMessage()
        self.adjustTextFieldWithKeyBoard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().isEnabled = true
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.removeKeyBoardObserver()
            if groupId != nil {
                Socketton.shared.subscribeGroupChannel(groupId: groupId, userId: Storage.shared.getUserId() ?? "",leave: true)
            }
            NotificationCenter.default.removeObserver(self, name: Notification.Name(HObservers.updateGroupNameImage), object: nil)
        }
        currentChatUserId = nil
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        self.individualNameLbl.text = individualName.capitalized
        typeMessageView.layer.cornerRadius = typeMessageView.bounds.height / 2
        getChatDetailRequest(isReload: true, count: 0)
        self.headerView.backgroundColor = .clear
        self.chatTV.tableHeaderView = nil
    }
    @objc func updateGroupDetail(notification: Notification) {
        if let detail = notification.userInfo {
            if let nme = detail["name"] as? String {
                self.individualNameLbl.text = nme
            }
        }
    }
    func scrollToBottom() {
        if messages.count > 0 {
            self.chatTV.scrollToRow(at: NSIndexPath.init(row: messages.count - 1, section: 0) as IndexPath, at: .bottom, animated: true)
        } else {
            print("No Message List found")
        }
    }
    
    func scroll(offset: Int) {
        if messages.count > 0 {
            self.chatTV.scrollToRow(at: NSIndexPath.init(row: offset, section: 0) as IndexPath, at: .top, animated: false)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = max(0.0, chatTV.contentOffset.y)
        let visibleCells = chatTV.visibleCells
        if let topCell = visibleCells.first,
           let indexPath = chatTV.indexPath(for: topCell) {
            let pt: CGPoint = CGPoint(x: 0, y: y)
            if self.isLoadMore {
                if let idx = chatTV.indexPathForRow(at: pt), idx.row == 3 {
                    self.isLoadMore = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.getChatDetailRequest(isReload: false, count: self.messages.count)
                    }
                }
            }
        }
    }
    func isMessageReceived() {
        Socketton.shared.isMessageReceivedCallback = { json in
            print(json)
            print("Message Json = \(json)")
            if self.viewIfLoaded?.window != nil {
                let chat = ChatData(json)
                if chat.senderId == self.toID {
                    self.messages.append(chat)
                    self.chatTV.reloadData()
                    self.scrollToBottom()
                    self.emitSeen()
                }
            }
        }
    }
    func isGroupMessageReceived() {
        Socketton.shared.isGroupMessageReceived = { json in
            print(json)
            print("Message Json = \(json)")
            if self.viewIfLoaded?.window != nil {
                let chat = ChatData(json)
                    self.messages.append(chat)
                    self.chatTV.reloadData()
                    self.scrollToBottom()
                    self.emitSeen()
                self.isMemberExists = chat.isMemberExists ?? true
                if chat.actionPerformedOn != nil{
                    if chat.actionPerformedOn.userId == Storage.shared.getUserId() {
                        self.showHideExistanceInGroup(checkLeave: true)
                    }
                }
            }
        }
    }
    func showHideExistanceInGroup(checkLeave:Bool = false) {
        if !isMemberExists && groupId != nil {
            noMemberView.isHidden = false
            if checkLeave {
                Socketton.shared.subscribeGroupChannel(groupId: groupId, userId: Storage.shared.getUserId() ?? "",leave: true)
            }
        } else {
            noMemberView.isHidden = true
        }
    }
    func isErrorRecievedWhileSendingMessage() {
        Socketton.shared.isErrorReceived = { json in
            if let msg = json["message"] as? String {
                Alert().showAlert(message: msg)
            } else {
                Alert().showAlert(message: "Error while sending message. Please try again later")
            }
        }
    }
    func emitSeen() {
        Socketton.shared.seenEmit(json: ["senderId":self.toID,"receiverId":Storage.shared.readUser()?.userId ?? ""])
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.hasText == true && textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
            //            sendBtn.isEnabled = true
        } else {
            //            sendBtn.isEnabled = false
        }
    }
    func adjustTextFieldWithKeyBoard() {
        
        self.setupAutoAdjust(table: chatTV) { (inset) in
            if inset.bottom == 0{
                self.messageTFBottomConstraint.constant = inset.bottom + 10
            }else {
                self.messageTFBottomConstraint.constant = (inset.bottom - 130) + 150
            }
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: {finished in
                self.scrollToBottom()
            })
        }
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
    
    func sendMessage(image:String? = nil) {
        if image != nil {
            var sendMessageData = ["senderId":Storage.shared.readUser()!.userId!,"receiverId":toID ?? "","sentAt":Date().dateInseconds(),"userName":toName ?? ""] as [String : Any]
            sendMessageData["message"] = image
            sendMessageData["type"] = MessageType.image.type()
            messages.append(ChatData(sendMessageData))
            print("Messages = \(messages.last?.message ?? "")")
            chatTV.reloadData()
            scrollToBottom()
            if groupId != nil {
                sendMessageData["receiverId"] = groupId
                sendMessageData["isGroupMessage"] = true
                Socketton.shared.sendGroupMessage(json: sendMessageData)
            } else {
                Socketton.shared.sendMessage(json: sendMessageData )
            }
            messsageTF.text = ""
        } else {
            if messsageTF.text == "" {
                Alert().showAlertWithAction(title: "", message: "Please write a message to send.", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            } else {
                var sendMessageData = ["senderId": Storage.shared.readUser()!.userId!,"receiverId": toID ?? "","sentAt": Date().dateInseconds(),"userName": toName ?? ""] as [String: Any]
                sendMessageData["message"] = messsageTF.text ?? ""
                sendMessageData["type"] = MessageType.text.type()
                messages.append(ChatData(sendMessageData))
                print("Messages = \(messages.last?.message ?? "")")
                chatTV.reloadData()
                scrollToBottom()
                if groupId != nil {
                    sendMessageData["receiverId"] = groupId
                    sendMessageData["isGroupMessage"] = true
                    Socketton.shared.sendGroupMessage(json: sendMessageData)
                } else {
                    Socketton.shared.sendMessage(json: sendMessageData )
                }
                messsageTF.text = ""
            }
        }
    }
    
    @IBAction func plusButtonClicked(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    //MARK: - IB Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func groupDetailAction(_ sender: Any) {
        if groupId != nil{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailController") as! GroupDetailController
            vc.groupId = groupId
            vc.isMemberExists = isMemberExists
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func sendMessageTapped(_ sender: Any) {
        sendMessage()
    }
    func callUploadMediaFileToServer(fileData: Data, image: UIImage?) {
        Constant.appDelegate.showProgressHUD(view: self.view)
        AuthenticationRequest().uploadMultipleImages(images: [image!], imageParam: "image") { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            self.view.isUserInteractionEnabled = true
            if error == nil{
                if let data = response?["data"] as? Dictionary<String,Any>,let url = data["url"] as? String {
                    print("url", url)
                    self.sendMessage(image: url)
                }
            } else {
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong please try again later.", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
}
extension IndividualChatDetailVC {
    func getChatDetailRequest(isReload: Bool, count: Int) {
        if isReload {
            Constant.appDelegate.showProgressHUD(view: self.view)
            self.chatTV.tableHeaderView = nil
        } else {
            self.chatTV.tableHeaderView = self.headerView
            self.indicatorView.startAnimating()
        }
        var offset: Int = 0
        if count > 0 {
            offset += count
        }
        LoggedInRequest().getChatDetailRequest(groupId:groupId,offset: offset ,limit: 200, userId: self.toID, params: [:]) { ( response,chatData,user,totalCount, error) in
            Constant.appDelegate.hideProgressHUD()
            self.chatTV.tableHeaderView = nil
            self.indicatorView.stopAnimating()
            if error == nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                guard let data = jsonData else { return }
                do {
                    let responseData = try? JSONDecoder().decode(GetUserChatDetailData.self, from: data)
                    self.getUserChatDetailData = responseData
                } catch let err {
                    print("Err", err.localizedDescription)
                }
                self.totalCount = totalCount
                if isReload {
                    self.messages = chatData!
                } else {
                    var chat = [ChatData]()
                    chat = chatData!
                    self.addedMessageCount = chatData!
                    chat.append(contentsOf: self.messages)
                    self.messages = chat
                }
                print("self.messages.count2", self.messages.count)
                self.chatUserDetail = user
                self.isLoadMore = self.messages.count < totalCount
                self.chatTV.reloadData()
                if isReload {
                    self.scrollToBottom()
                } else {
                    print("self.addedmessage", self.addedMessageCount.count)
                    self.scroll(offset: self.addedMessageCount.count)
                }
                self.emitSeen()
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}
extension IndividualChatDetailVC {
    func setupAutoAdjust(table:UITableView?,completitionHandler:((UIEdgeInsets) -> Void)?) {
        self.completition = completitionHandler

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardshown), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardhide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyBoardObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardshown), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardhide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardshown(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.fitContentInset(inset: UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0))
        }
    }
    @objc func keyboardhide(_ notification:Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.fitContentInset(inset: .zero)
        }
        
    }
    func fitContentInset(inset:UIEdgeInsets!) {
        if let completitionClosure = completition, let inst =  inset {
            completitionClosure(inst)
        }
    }
}
extension IndividualChatDetailVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ChatTVC!
        if messages[indexPath.row].senderId == Storage.shared.getUserId() {
            if messages[indexPath.row].type == MessageType.image.type() {
                cell = tableView.dequeueReusableCell(withIdentifier: "senderImageCell") as? ChatTVC
            } else if messages[indexPath.row].type == MessageType.display.type() {
                cell = tableView.dequeueReusableCell(withIdentifier: "displayCell") as? ChatTVC
                cell.dateLbl.text = ""
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "senderCell") as? ChatTVC
            }
        } else {
            if messages[indexPath.row].type == MessageType.image.type() {
                cell = tableView.dequeueReusableCell(withIdentifier: "recieverImageCell") as? ChatTVC
            } else if messages[indexPath.row].type == MessageType.display.type() {
                cell = tableView.dequeueReusableCell(withIdentifier: "displayCell") as? ChatTVC
                cell.dateLbl.text = ""
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "reciverCell") as? ChatTVC
                cell.nameLbl.text = ""
            }
        }
        if messages[indexPath.row].type == MessageType.image.type() {
            cell.sharedImage.applyCorner(10)
            cell.sharedImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.sharedImage.sd_setImage(with: URL(string:messages[indexPath.row].message ?? ""))
            let msg = self.messages[indexPath.row]
            let time = self.timeStringFromUnixTime(unixTime: Double(msg.sentAt ?? 0))
            cell.timeLbl.text = "\(time)"
            cell.isUserInteractionEnabled = true
        } else {
            cell.messageLbl.text = messages[indexPath.row].message
            let msg = self.messages[indexPath.row]
            if messages[indexPath.row].type == MessageType.display.type() {
                var ttpe = GroupChatActions.removed
                switch (messages[indexPath.row].actionType ?? "") {
                case "removed":
                    ttpe = .removed
                case "left":
                    ttpe = .left
                case "imageChange":
                    ttpe = .imageChange
                case "nameChange":
                    ttpe = .nameChange
                case "groupCreated":
                    ttpe = .groupCreated
                case "addMember":
                    ttpe = .addMember
                default:
                    break;
                }
                if self.messages[indexPath.row].actionPerformedOn != nil || self.messages[indexPath.row].actionPerformedBy != nil {
                    cell.messageLbl.text = ttpe.type(actionon: self.messages[indexPath.row].actionPerformedOn, actionby: self.messages[indexPath.row].actionPerformedBy)
                }
            }
            let time = self.timeStringFromUnixTime(unixTime: Double(msg.sentAt ?? 0))
            if cell.timeLbl != nil {
                cell.timeLbl.text = "\(time)"
            }
        }
        if let date = dateTime(indexPath: indexPath) {
            cell.dateLbl.text = date
        } else {
            cell.dateLbl.text = ""
        }
        if groupId != nil && cell.nameLbl != nil {
            cell.nameLbl.text = messages[indexPath.row].senderFullName
            cell.nameLbl.textColor = UIColor().randomColor(seed: messages[indexPath.row].senderFullName ?? "")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if messages[indexPath.row].type == MessageType.image.type() {
            let vc = PreviewViewController.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
            vc.url = self.messages[indexPath.row].message ?? ""
            vc.fromChatVC = true
            self.present(vc, animated: true)
        }
    }
    func dateTime(indexPath: IndexPath) -> String? {
        let msg = self.messages[indexPath.row]
        var predate = Date()
        if indexPath.item != 0 {
            predate = self.messages[indexPath.row - 1].sentAt?.dateFromTimeStamp().addingTimeInterval(0) ?? Date()
        }
        let msgdate = msg.sentAt?.dateFromTimeStamp().addingTimeInterval(0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateToPrint: NSString = dateFormatter.string(from: msgdate ?? Date()) as NSString
        let predateToPrint: NSString = dateFormatter.string(from: predate) as NSString
        
        if indexPath.item == 0 || dateToPrint != predateToPrint {
            if Calendar.current.isDateInToday(dateFormatter.date(from: dateToPrint as String)!) {
                return  "Today"
            } else if Calendar.current.isDateInYesterday(dateFormatter.date(from: dateToPrint as String)!) {
                return  "Yesterday"
                
            } else if get_WeekDay(date: dateFormatter.date(from: dateToPrint as String)!) {
                dateFormatter.dateFormat = "EEEE hh:mm a"
                return  dateFormatter.string(from: (msg.sentAt?.dateFromTimeStamp())!)
            } else {
                dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
                return  dateFormatter.string(from: (msg.sentAt?.dateFromTimeStamp())!)
            }
        }
        return nil
    }
    func  get_WeekDay(date:Date) -> Bool {
        let currentComponent = Calendar.current.component(.weekOfYear, from: Date())
        
        let component = Calendar.current.component(.weekOfYear, from: date)
        if currentComponent == component || currentComponent == component+1 {
            if  currentComponent == component+1 {
                if Calendar.current.component(.weekday, from: Date()) < Calendar.current.component(.weekday, from: date) {
                    return true
                } else {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension IndividualChatDetailVC: ImagePickerDelegate {
  func didSelect(image: UIImage?, data: Data?) {
    callUploadMediaFileToServer(fileData: data!, image: image)
  }
}
extension UIColor {
    func randomColor(seed: String) -> UIColor {
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
