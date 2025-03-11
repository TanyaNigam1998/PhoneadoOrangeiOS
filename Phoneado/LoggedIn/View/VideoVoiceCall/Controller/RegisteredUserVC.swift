//
//  RegisteredUserVC.swift
//  Phoneado
//
//  Created by Tanya Nigam on 25/02/25.
//

import UIKit
import TwilioVideo

class RegisteredUserVC: UIViewController, UITextFieldDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRecord: UILabel!
    @IBOutlet weak var searchView: UIView!
    
    // MARK: - Variables
    var mobileListData: [MobileList] = []
    var sectionTitles = [String]()
    var contactsWithSections = [[MobileList]]()
    let collation = UILocalizedIndexedCollation.current()
    var userLoginType = ""
    var getContactsData: GetContactsData?
    var myContactEnabled: Bool = true
    var roomSid: String?
    var roomName: String?
    var otherUserId: String?
    var comingFrom: Bool = false
    var heading: String = ""
    var remoteParticipants: Array<RemoteParticipant> = []
    var contacts = [Contact]()
    var allUsers = [MobileList]()
    var filterUsers = [MobileList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLoginType = Storage.shared.isAdminUser() ?? "Admin"
        contacts = AllContacts
        setView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showContacts()
    }
    
    // MARK: - Custom Functions
    func setView() {
        titleLbl.font = UIFont(name: "Lato-Bold", size: 18)
        titleLbl.text = heading
        searchView.layer.cornerRadius = searchView.bounds.height / 2
        searchView.borderWidth = 1
        searchView.borderColor = UIColor.homeSearchViewBorderColor
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "HomeContactsTVC", bundle: nil), forCellReuseIdentifier: "HomeContactsTVC")
        searchTextField.delegate = self
    }
    
    func showContacts() {
        if self.comingFrom {
            let matchedUsers = allUsers.filter { user in
                return self.remoteParticipants.contains { $0.identity == user.userId }
            }
            self.filterUsers = matchedUsers
            self.groupContactsByFirstLetter(matchedUsers)
            if self.sectionTitles.count > 0 {
                self.searchTextField.placeholder = "\(matchedUsers.count) Contacts"
            } else {
                self.searchTextField.placeholder = "0 Contacts"
            }
        } else {
            self.groupContactsByFirstLetter(allUsers)
            if self.sectionTitles.count > 0 {
                self.searchTextField.placeholder = "\(allUsers.count) Contacts"
            } else {
                self.searchTextField.placeholder = "0 Contacts"
            }
        }
        self.tableView.reloadData()
    }
    
//    @objc func setUpCollation() {
//        let (arrayContacts, arrayTitles) = collation.partitionObjects(array: self.contacts, collationStringSelector: #selector(getter: Contact.givenName))
//        self.contactsWithSections = arrayContacts as! [[MobileList]]
//        self.sectionTitles = arrayTitles
//        if self.sectionTitles.count > 0 {
//            self.searchTextField.placeholder = "\(self.contacts.count) Contacts"
//        } else {
//            self.searchTextField.placeholder = "0 Contacts"
//        }
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string).lowercased()
            
            if updatedText.isEmpty {
                // Reset to original grouped contacts
                self.groupContactsByFirstLetter(self.comingFrom ? filterUsers : allUsers)
            } else {
                // Filter the contacts based on search text
                let filteredContacts = (self.comingFrom ? filterUsers : allUsers).filter {
                    ($0.fullName?.lowercased() ?? "").contains(updatedText)
                }
                self.groupContactsByFirstLetter(filteredContacts)
            }
            tableView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - IBActions
    @IBAction func backBtnAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Custom Function
    private func groupContactsByFirstLetter(_ contacts: [MobileList]) {
        self.contactsWithSections.removeAll()
        self.sectionTitles.removeAll()
        
        let groupedDictionary = Dictionary(grouping: contacts) { (contact) -> String in
            return String(contact.fullName?.prefix(1) ?? "").uppercased()
        }
        
        self.sectionTitles = groupedDictionary.keys.sorted()
        self.contactsWithSections = self.sectionTitles.map { groupedDictionary[$0] ?? [] }
    }
    
    func addParticipants(roomSid: String, roomName: String, otherUserId: String, completion: @escaping () -> Void) {
        var param: [String: Any] = [:]
        param.updateValue(roomSid, forKey: "roomSid")
        param.updateValue(roomName, forKey: "roomName")
        param.updateValue(otherUserId, forKey: "otherUserId")
        self.view.endEditing(true)
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().addMembersonCall(params: param) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil {
                print("participant added")
                completion()
            } else {
                Alert().showAlert(message: error?.message ?? TextString.inValidResponseError)
            }
        }
    }
}

// MARK: - Extensions
extension RegisteredUserVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsWithSections[section].count > 0 ? contactsWithSections[section].count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if contactsWithSections[indexPath.section].count == 0 {
            noRecord.isHidden = false
        } else {
            noRecord.isHidden = true
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeContactsTVC", for: indexPath) as! HomeContactsTVC
            cell.selectionStyle = .none
            let contact = contactsWithSections[indexPath.section][indexPath.row]
            cell.contactName.text = contact.fullName
            if let profilePic = contact.profilePic, !profilePic.isEmpty {
                cell.contactImg.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named: "user"))
            } else {
                cell.contactImg.image = UIImage(named: "user")
            }
            cell.favoriteImageView.isHidden = true
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
    
        let titleLabel = UILabel()
        titleLabel.text = sectionTitles[section]
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorView = UIView()
        separatorView.borderColor = UIColor.lightBorderColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -5),
            
            separatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
            separatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0),
            separatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = contactsWithSections[indexPath.section][indexPath.row]
        otherUserId = selectedUser.userId
        addParticipants(roomSid: roomSid ?? "", roomName: roomName ?? "", otherUserId: otherUserId ?? "") {
            self.dismiss(animated: true)
        }
    }
}
