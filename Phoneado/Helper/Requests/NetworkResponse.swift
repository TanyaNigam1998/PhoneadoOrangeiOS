
import Foundation
import Alamofire

class NetworkResponse {
    
    var rawResponse: DataResponse<Any,AFError>
    var data: AnyObject?
    var dataCollection: NSArray?
    var error: String?
    var statusCode: Int?
    var success:Bool = false
    // var status = 0
    
    init?(response: DataResponse<Any,AFError>){
        
        self.rawResponse = response
        if self.rawResponse.response != nil{
            self.statusCode = self.rawResponse.response!.statusCode
        }
        self.success = self.statusCode == 200
        switch response.result {
        case .success(let value):
            if let result = value as? NSDictionary {
                if let error = result["data"] , !success {
                    self.success = false
                    if let message = error as? String {
                        self.error = message
                    }else if let errorInfo = error as? Dictionary<String, Any>{
                        if let messages = errorInfo["message"] as? String {
                            self.error = messages
                        }else{
                            self.error = TextString.inValidResponseError
                        }
                    }else {
                        self.error = TextString.inValidResponseError
                    }
                }
                else {
                    if let header = response.response?.allHeaderFields as? Dictionary<String,Any>, ((header["Authorization"] as? String) != nil) {
                        Storage.shared.save(item: header["Authorization"] as! String, forKey: UserDefault.appToken)
                        print("App Token = \(Storage.shared.readObject(forKey: UserDefault.appToken) ?? "")")
                    }
                    self.data = result as AnyObject?
                }
            } else {
                if let result = value as? NSArray {
                    self.data = result as AnyObject?
                }else{
                    self.error = TextString.inValidResponseError
                }
            }
            break
        case.failure(let error):
            self.error = error.localizedDescription
            break
        
        }
    }
    
    func isSuccessful()->Bool {
        return self.success
    }
    
    func getError()->NetworkError {
        return NetworkError(error: self.error ?? TextString.inValidResponseError)
    }
    
}
