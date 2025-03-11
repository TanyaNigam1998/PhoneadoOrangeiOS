import UIKit
import SwiftyJSON
import Alamofire

class handleError: NSObject {
    static var shared = handleError()
    
    
    
//    func HandlejsonData (dataResponse:DataResponse<Data>, success: @escaping(Any) -> Void ,failure:@escaping (NSError) -> Void)->Void{
//        Constant.appDelegate.hideProgressHUD()
//
//
//        if((dataResponse.response?.statusCode) != nil){
//
//            if dataResponse.response?.statusCode == 200 {
//
//                let json = JSON(dataResponse.data!)
//                let dict = json.object
//                success(dict)
//
//                //success(json.dictionaryObject! as NSDictionary,dataResponse.response!.statusCode)
//
//            } else{
//                let json = JSON(dataResponse.data!)
//                let dict = json.object
//
//                guard let dict1 = dict as? NSDictionary else {return}
//                if dict1.value(forKey: "statusCode") as? Int == 401 || dict1.value(forKey: "statusCode") as? Int == 403 {
//                   // Constant.KAppDelegate.logOutApp()
//                    return
//                }
//
//                if(dict1.value(forKey: "data") as? String != nil){
//                    //Utility.showWindowAlert(title: "", message:(dict.value(forKey: "data") as! String) )
//                    Constant.appDelegate.showError(msg: dict1.value(forKey: "data") as! String)
//                    //self.showErrorMsg(str: (dict1.value(forKey: "data") as! String))
//                }
//                success(dict)
//                //Constant.KAppDelegate.hideProgressHUD()
//                return
//            }
//
//        }else{
//            let err = dataResponse.error
//            failure(err! as NSError)
//            Constant.appDelegate.hideProgressHUD()
//            showErrorMsg(str: Constant.ServerError)
//        }
//    }
//
//    func showErrorMsg(str: String){
//        Constant.appDelegate.hideProgressHUD()
//       // Utility.showWindowAlert(title: "", message:str )
//         Constant.appDelegate.showError(msg:str)
//    }
}
