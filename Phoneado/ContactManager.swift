//
//  ContactManager.swift
//  Tokpee
//
//  Created by ZimTej on 2/14/20.
//  Copyright © 2020 ZimbleCode. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class ContactManager {
     var contactStore = CNContactStore()
    var contacts = [CNContact]()
    static let shared = ContactManager()

    func fetchContacts(completitionHandler: @escaping (([CNContact]) -> Void)){
        contactStore.requestAccess(for: (.contacts)) { (granted, err) in
            if let err = err {
                print("Failed to request access", err)
                return
            }
            if granted {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.contacts.removeAll()
                    let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactEmailAddressesKey,
                                CNContactPhoneNumbersKey,CNLabelPhoneNumberMobile,CNContactGivenNameKey,CNContactFamilyNameKey,
                                CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactDepartmentNameKey,CNContactIdentifierKey] as [Any]
                    let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
                    request.sortOrder = CNContactSortOrder.givenName
                    
                    do {
                        try self.contactStore.enumerateContacts(with: request) { (contact, stop) in
                            self.contacts.append(contact)
                        }
                    } catch {
                        print("unable to fetch contacts")
                    }
                    DispatchQueue.main.async {
                        completitionHandler(self.contacts)
                    }
                }
            }
        }
    }
}
