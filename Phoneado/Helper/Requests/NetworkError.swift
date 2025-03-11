//
//  NetworkError.swift

//

import Foundation

class NetworkError {
    
    var code: Int = 0
    
    var message: String = "An unknown error occured"
    
    init(error: Any, code: Int? = nil){
        
        if let err = error as? NSError {
            self.message = err.localizedDescription
            self.code = err.code
        }else{
            if let desc = error as? String {
                self.message = desc
            }
            if (code != nil) {
                self.code = code!
            }
        }
        
    }
}
