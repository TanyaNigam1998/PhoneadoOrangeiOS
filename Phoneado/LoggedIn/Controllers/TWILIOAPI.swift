//
//  UserAPIRegister.swift
//  Cloud Seat
//
//  Created by Ishan Grover on 21/11/19.
//  Copyright © 2019 CYL8R. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Reachability

class TWILIOAPI: NetworkRequest {
    
    static private var createRoom = "call/createRoom"
    static private var getToken = "call/getToken"
    static private var endcall = "call/endCall"

    static private let reachAbility:Reachability = Reachability()!
    

    class private func showErrorMsg(str: String){
        Constant.appDelegate.hideProgressHUD()
        //Constant.appDelegate.showError(msg: str)
    }
    
    func createRoom(bookingId:String,email:String, callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        
        let endPoint = "call/createRoom?bookingId=\(bookingId)&email=\(email)"
        
        self.getEncodedUrl(endPointUrl: endPoint, callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })

    }
    
    
    func getToken(bookingId:String,email:String, callback: @escaping ( Dictionary<String, Any>?,NetworkError?) -> ()) {
        
        let endPoint = "call/createRoom?bookingId=\(bookingId)&email=\(email)"
        
        self.getEncodedUrl(endPointUrl: endPoint, callback: { (response, error) in
            if  error != nil {
                callback(nil, error)
            }
            else {
                if let data = response!.data?["data"] as? Dictionary<String, Any> {
                    callback(data, nil)
                }
            }
        })

    }

    
    class func getToken(bookingId:String,email:String,success :@escaping (NSDictionary) -> Void ,failure:@escaping (NSError) -> Void) -> Void{
      if(self.reachAbility.connection != .none){
          
          
        Alamofire.request("\(Constant.BASE_URL)\(getToken)?bookingId=\(bookingId)&email=\(email)", method : .get, parameters:nil, encoding : JSONEncoding.default , headers : Headers.headers()).responseData { dataResponse in
          handleError.shared.HandlejsonData(dataResponse: dataResponse, success: { (dict) in
            //print(dict)
            success(dict as! NSDictionary)
           
          }, failure: { (err) in
            failure(err)
          })
        }
      }else{
        //Utility.showWindowAlert(title: "", message: Constant.ConnectivityError)
        self.showErrorMsg(str: Constant.ConnectivityError)
         
      }
       
    }
    
    
    class func cancelCallByCelebrity(isCancel:String,bookingId:String,success :@escaping (NSDictionary) -> Void ,failure:@escaping (NSError) -> Void) -> Void{
      if(self.reachAbility.connection != .none){
        Alamofire.request("\(Constant.BASE_URL)\(endcall)?bookingId=\(bookingId)&unanswered=\(isCancel)", method : .get, parameters:nil, encoding : JSONEncoding.default , headers : Headers.headers()).responseData { dataResponse in
          handleError.shared.HandlejsonData(dataResponse: dataResponse, success: { (dict) in
            //print(dict)
            success(dict as! NSDictionary)
           
          }, failure: { (err) in
            failure(err)
          })
        }
      }else{
        self.showErrorMsg(str: Constant.ConnectivityError)
         
      }
       
    }


    
    class func cancelCall(isCancel:String,bookingId:String,email:String,timeLeft:Int,success :@escaping (NSDictionary) -> Void ,failure:@escaping (NSError) -> Void) -> Void{
        
        
        print("Cancel call calling....")
        
      if(self.reachAbility.connection != .none){
        Alamofire.request("\(Constant.BASE_URL)\(endcall)?bookingId=\(bookingId)&rejected=\(isCancel)&email=\(email)&timeLeft=\(timeLeft)", method : .get, parameters:nil, encoding : JSONEncoding.default , headers : Headers.headers()).responseData { dataResponse in
          handleError.shared.HandlejsonData(dataResponse: dataResponse, success: { (dict) in
            //print(dict)
            success(dict as! NSDictionary)
           
          }, failure: { (err) in
            failure(err)
          })
        }
      }else{
        self.showErrorMsg(str: Constant.ConnectivityError)
         
      }
       
    }
    
}


