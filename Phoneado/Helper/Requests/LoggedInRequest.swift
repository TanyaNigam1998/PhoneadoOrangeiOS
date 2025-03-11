
import UIKit
import Foundation
import Alamofire

class LoggedInRequest: NetworkRequest {
    func uploadContactsRequest(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/contact", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }

    func deleteApp(callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.delete(endPointUrl: "/api/auth", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }

    func checkVersion(versionStatus: String, callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/version/check?v=\(versionStatus)&appType=ios", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
        
    }
  
    func genrateTwilioVoiceToken(otherUserId: String, callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/call/getToken/voice?type=ios", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }

    func createRoomVideo(otherUserId: String, callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/call/createRoom/v1?otherUserId=\(otherUserId)", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }
    
    func getVideoToken(otherUserId: String, callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/call/getToken?\(otherUserId)", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }
    
    func endCall(otherUserId: String, callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/call/endCall?\(otherUserId)", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                callback((response!.data as! Dictionary<String, Any>), nil)
                
            }
        })
    }
    
    func getContactsRequest(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/contact", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }
    func getFavouritesRequest(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/contact/favorite", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }
    func updateCallStatus(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/call/status", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    
    func addToFavouriteContactRequest(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/contact/favorite", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    func deleteFavouriteContactRequest(contactID:String,params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.deleteURLENcoded(endPointUrl: "/api/contact/favorite/\(contactID)", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    func uploadGalleryImagesRequest(imageIndex: Int,imagesData: Data,params: [String: Any],vidData: Array<Data>?, callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.postwithMultipart(endPointUrl: "/api/image", params: params, imagesData: imagesData, imageIndex: imageIndex, vidData: vidData) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    func uploadMultipleImages(param: [String: Any] = [:],images:Array<UIImage>,callback: @escaping (Dictionary<String,Any>?, NetworkError?) -> ()) {
        for i in 0..<images.count {
            self.postwithMultipart(endPointUrl: "/api/image/s3-upload", params:[:], imagesData: [images[i].jpegData(compressionQuality: 0.5)!], vidData: nil) { (response, error) in
                if error != nil{
                    callback(nil,error)
                } else {
                    callback(response?.data as? Dictionary<String,Any>,error)
                }
            }
        }
    }
    func getGalleryImagesRequest(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/image", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }
    func getImagesUniqueIDRequest(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/image", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> { //?["data"]
                    callback(data, nil)
                }
            }
        })
    }
    func getChatRequest(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/chat/summary", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
                //                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                //                    callback(data, nil)
                //                }
            }
        })
    }
    
    func getUserProfile(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/users/profile", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
                //                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                //                    callback(data, nil)
                //                }
            }
        })
    }
    
    func getProfile(number: String,params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        self.getEncodedUrl(endPointUrl: "/api/users/profile?otherUserNumber=\(number)", callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
                //                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                //                    callback(data, nil)
                //                }
            }
        })
    }
    
    func getCallLogs(fromContactVC: Bool, offset: Int, params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        var endpoint: String = ""
        if fromContactVC
        {
            let userId = params["userId"] as! String
            endpoint = "/api/call/history?offset=\(offset)&limit=100&otherUserId=\(userId)"
        }else
        {
            endpoint = "/api/call/history?offset=\(offset)&limit=100"
        }
        
        print("endpoint", endpoint)
        self.getEncodedUrl(endPointUrl: endpoint, callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }
    
    func getSearchCallLogs(fromContactVC: Bool, text: String, offset: Int, params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        var endpoint: String = ""
        endpoint = "/api/call/history?offset=\(offset)&text=\(text)"
        
        print("endpoint", endpoint)
        self.getEncodedUrl(endPointUrl: endpoint, callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })
    }
    
    func checkRegisteredMobileRequest(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/contact/checkContacts", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    
    func addMembersonCall(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/call/addParticipant", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    
    func exitCall(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/call/exitCall", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                if let data = response!.data as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    
    func getChatDetailRequest(groupId:String? = nil,offset:Int ,limit:Int,userId:String,params: [String:Any], callback: @escaping ( Dictionary<String,Any>?,[ChatData]?,ChatUser?,Int ,NetworkError?) -> ()) {
        var endPoint = "/api/chat/individual?userId=\(userId)&offset=\(offset)&limit=\(limit)"
        print("endPoint", endPoint)
        if let gpId = groupId{
            endPoint = "/api/chat/individual?groupId=\(gpId)&offset=\(offset)&limit=\(limit)"
        }
        self.getEncodedUrl(endPointUrl: endPoint, params: params) { (response, error) in
            if  error != nil {
                callback(nil,nil,nil,0, error)
            }
            else {
                var chat = [ChatData]()
                var chatuserDetail : ChatUser?
                let detail = response!.data?["data"] as? Dictionary<String,Any>
                if let chatDetail = detail?["chatList"] as? Array<Dictionary<String,Any>> {
                    chat += chatDetail.map({return ChatData($0)})
                }
                let totalCount = detail?["totalCount"] as? Int ?? 0
                //                if let user = detail?["chatUser"] as? Dictionary<String,Any> {
                //                    chatuserDetail = Chatuser(data: user)
                //                }
                callback(detail,chat,chatuserDetail,totalCount, nil)
            }
        }
    }
    
    func updateUser(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        
        self.put(endPointUrl: "/api/users", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else
            {
                if let data = response!.data?["data"] as? Dictionary<String, Any>, let user = data["user"] as?  Dictionary<String, Any>{
                    callback(user, nil)
                }else if let data = response!.data?["data"] as? Dictionary<String, Any>, let user = data["response"] as?  Dictionary<String, Any>{
                    callback(user, nil)
                }
                else if let data = response!.data?["data"] as? Dictionary<String, Any>{
                    callback(data, nil)
                }
            }
        }
    }
    
    func createOTP(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()){
        self.post(endPointUrl: "/api/otp/create", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    
    func verifyPin(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()){
        self.post(endPointUrl: "/api/auth/password/verify", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    
    func changePin(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()){
        self.post(endPointUrl: "/api/auth/password/change", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    func playSound(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()){
        self.post(endPointUrl: "/api/users/ring-phone", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    //MARK: Group Chat
    func createGroup(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()){
        self.post(endPointUrl: "/api/groups", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    func groupDetail(groupId: String,params:[String:Any] = [:], callback: @escaping ( [UserDetail]?,GroupDetail?,NetworkError?) -> ()) {
        
        self.getEncodedUrl(endPointUrl: "/api/groups/\(groupId)", params: params) { (response, error) in
            if  error != nil {
                callback(nil,nil, error)
            } else {
                var chat = [UserDetail]()
                var chatuserDetail = GroupDetail()
                let detail = response!.data?["data"] as? Dictionary<String,Any>
                if let chatDetail = detail?["groupMembers"] as? Array<Dictionary<String,Any>> {
                    chat += chatDetail.map({return UserDetail($0)})
                }
                if let user = detail?["group"] as? Dictionary<String,Any> {
                    chatuserDetail = GroupDetail(data: user)
                }
                callback(chat,chatuserDetail, nil)
            }
        }
    }
    func deleteGroup(id: String, callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        self.delete(endPointUrl: "/api/groups/\(id)") { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    func leaveGroup(groupId: String, params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        
        self.delete(endPointUrl: "/api/groups/member/\(groupId)", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    func editGroup(params: [String: Any], callback: @escaping ( Dictionary<String, Any>?, NetworkError?) -> ()) {
        
        self.put(endPointUrl: "/api/groups", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            } else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
}
