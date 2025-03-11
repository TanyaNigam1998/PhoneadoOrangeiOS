
import UIKit
import Foundation
import Alamofire
import Reachability
class AuthenticationRequest: NetworkRequest
{
    
    static private let urlStr = "s3upload/image-upload"
    static public var params:[String:Any] = [:]
    static private let reachAbility:Reachability = Reachability()!
    
    func verifyAccountExists(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        
        self.post(endPointUrl: "api/user/verifyCredentials", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data?["data"] as? Dictionary<String, Any>{
                    callback(data, nil)
                }
            }
        }
    }
    func signup(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/users", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data?["data"] as?  Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    
    func login(params: [String:Any], callback: @escaping (Dictionary<String, Any>?,NetworkError?) -> ()) {
        self.post(endPointUrl: "/api/auth/login", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data?["data"] as?  Dictionary<String, Any> {
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
    func verify(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()){
        self.post(endPointUrl: "/api/otp/verify", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data?["data"] as?  Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        }
    }
    func forgotPassword(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ())
    {
        self.post(endPointUrl: "/api/auth/password/reset/mobile", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    
    func changePassword(params: [String:Any], callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ())
    {
        self.post(endPointUrl: "/api/auth/password/change/", params: params) { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                callback(response!.data as? Dictionary<String, Any>, nil)
            }
        }
    }
    
    func uploadMultipleImages( param:[String:Any] = [:],images:Array<UIImage>,imageParam: String,callback:@escaping (Dictionary<String,Any>?,NetworkError?) -> ()){
        for i in 0..<images.count
        {
            self.postwithMulti(endPointUrl: "/api/image", imageParam : imageParam, params:[:], imagesData: [images[i].jpegData(compressionQuality: 0.7)!], imageIndex: i, vidData: nil) { (response, error) in
                if error != nil{
                    callback(nil,error)
                }else{
                    callback(response?.data as? Dictionary<String,Any>,error)
                }
            }
        }
    }
}
