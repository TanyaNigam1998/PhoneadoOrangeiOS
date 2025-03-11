//
//  Storage.swift
//  Quicklyn
//
//  Created by Zimble on 12/6/21.
//

import Foundation

class Storage {
    static let shared = Storage()
    
    func save(item: Any, forKey key: String) {
        UserDefaults.standard.set(item, forKey: key)
    }
    
    func readObject(forKey key: String) -> String? {
        if UserDefaults.standard.object(forKey: key) != nil{
            return UserDefaults.standard.string(forKey: key)

        }else{
            return ""
        }
    }
    
    func saveInterger(item: Int, forKey key: String) {
        UserDefaults.standard.set(item, forKey: key)
    }
    func readIntger(forKey key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func readBool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func remove(key:String){
        UserDefaults.standard.removeObject(forKey: key)
    }
    @available(iOS 11.0, *)
    func archieve(object: Any, toFile file: String) {
        let data = try! NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
        UserDefaults.standard.set(data, forKey: file)
    }
    func unarchieveObject(fromFile file: String) -> Any? {
        guard let data = UserDefaults.standard.data(forKey: file) else { return nil }
        
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
    }
    
    func saveStatus(type: String) {
        self.save(item: type, forKey: UserDefault.isAdmin)
        
    }
    
    func savephoneNumberr(type: String) {
        self.save(item: type, forKey: UserDefault.phoneNumber)
        
    }
    
    func saveUser(user: UserDetail) {
        removeArchieveObject(fromFile: UserDefault.loginUser)
        if #available(iOS 11.0, *) {
            if user.userId != nil{
                self.save(item: user.userId!, forKey: UserDefault.userId)
            }
            archieve(object: user, toFile: UserDefault.loginUser)
        } else {
            // Fallback on earlier versions
        }
    }
    func readUser() -> UserDetail? {
        if let user = unarchieveObject(fromFile: UserDefault.loginUser) as? UserDetail {
            return user
        }
        return nil
    }
    
    func getPhoneNumber() -> String?{
        return self.readObject(forKey: UserDefault.phoneNumber)!
    }

    func getUserId() -> String?{
        return self.readObject(forKey: UserDefault.userId)!
    }
    func getUserImage() -> String?{
        return self.readObject(forKey: UserDefault.profilePic)!
    }
    func getUserFirstName() -> String?{
        return self.readObject(forKey: UserDefault.firstName)!
    }
   
    func isAdminUser() -> String?{
        return self.readObject(forKey: UserDefault.isAdmin)!
    }

    
    func clearAllCachedData() {
       // DataBaseManager().deleteAllDataBase()
        removeArchieveObject(fromFile: UserDefault.loginUser)
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
          //  if key != Constants.UserDefault.email && key != Constants.UserDefault.password{
                defaults.removeObject(forKey: key)
           // }
        }
        UserDefaults.standard.synchronize()
    }
    
    func path(file: String) -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return documentDirectory! + "/" + file
    }
    func removeArchieveObject(fromFile file: String) {
        do {
            try FileManager.default.removeItem(atPath: path(file: file))
        } catch {
            
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
