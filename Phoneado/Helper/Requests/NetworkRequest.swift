//
//  NetworkRequest.swift

//

import Foundation
import Alamofire

class NetworkRequest{
    var accessToken: String = "" ;
    
    let reachability:Reachability = Reachability()!
    
    func post(endPointUrl: String, params: [String: Any]? = [:], callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequest(method: .post, endPoint: endPointUrl, params: params!, callback: callback)
    }
    func postURLENcoded(endPointUrl: String, params: [String: Any]? = [:], callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequestURLENcoded(method: .post, endPoint: endPointUrl, params: params!, callback: callback)
    }
    func get(endPointUrl: String, params: [String: Any]? = [:], callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequest(method: .get, endPoint: endPointUrl, params: params, callback: callback)
    }
    func getEncodedUrl(endPointUrl: String, params: [String: Any]? = [:], callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequestURLENcoded(method: .get, endPoint: endPointUrl, params: params, callback: callback)
    }
    func put(endPointUrl: String, params: [String: Any]? = [:], callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequest(method: .put, endPoint: endPointUrl, params: params, callback: callback)
    }
    func delete(endPointUrl: String, params: [String: Any]? = [:], callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequest(method: .delete, endPoint: endPointUrl, params: params, callback: callback)
    }
    func deleteURLENcoded(endPointUrl: String, params: [String: Any]? = [:], callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequestURLENcoded(method: .delete, endPoint: endPointUrl, params: params!, callback: callback)
    }
    func postwithMultipart(endPointUrl: String,imageParam:String = "image", params: [String: Any],imagesData:Data, imageIndex:Int?, vidData:Array<Data>?, callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequestWithMultipart(method: .post,endPoint: endPointUrl, params: params, imagesData:imagesData, videoData: vidData, imageIndex: imageIndex, imageParam:imageParam, callback: callback)
    }
    func postwithMultipart(endPointUrl: String,imageParam:String = "file", params: [String: Any]? = [:],imagesData:Array<Data>?,vidData:Array<Data>?,pdf:Data? = nil, callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequestWithMultipart(method: .post,endPoint: endPointUrl, params: params, imagesData:imagesData, videoData: vidData, pdf: pdf,imageParam:imageParam, callback: callback)
       }
    func postwithMulti(endPointUrl: String,imageParam:String = "image", params: [String: Any]? = [:],imagesData:Array<Data>, imageIndex:Int?, vidData:Array<Data>?, callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
        makeRequestWithMulti(method: .post,endPoint: endPointUrl, params: params, imagesData:imagesData, videoData: vidData, imageIndex: imageIndex, imageParam:imageParam, callback: callback)
       }
    
//    func postVideowithMultipart(endPointUrl: String,imageParam:String = "image", params: [String: Any]? = [:],vidData:Data, callback:  @escaping (NetworkResponse?, NetworkError?) ->()){
//        makeRequestVideoWithMultipart(method: .post,endPoint: endPointUrl, params: params, videoData: vidData,imageParam:imageParam, callback: callback)
//       }
    
    func cancelAllRequests(){
        AF.session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        })
    }
    func makeRequest(method: HTTPMethod, endPoint: String, params: [String: Any]? = [:], callback: @escaping (NetworkResponse?, NetworkError?) ->()) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if reachability.connection != .none
        {
            accessToken = Storage().readObject(forKey:UserDefault.appToken)!
            var headers: HTTPHeaders = [
                "Content-Type": "application/json"
            ]
            if (!self.accessToken.isEmpty) {
                headers["Authorization"] =  self.accessToken
            }
//            else {
//                let authorizationToken = Storage.shared.readObject(forKey: UserDefault.appToken) ?? ""
//                headers["Authorization"] = authorizationToken
//            }
            print("Headers = \(headers)")
            print("Request Url = \(Constant.BASE_URL + endPoint)")
            AF.request(Constant.BASE_URL + endPoint, method: method, parameters: params, encoding: JSONEncoding.default, headers:  headers ).validate(contentType: ["application/json"]).responseJSON { response in
                switch response.result {
                case .success(_ ):
                    //success, do anything
                    if let networkResponse = NetworkResponse(response: response)
                    {
                        print("networkResponse = \(networkResponse.statusCode ?? 0)")
                        if (!networkResponse.isSuccessful()) {
                            print("Response Status Code = \(networkResponse.statusCode ?? 0)")
                            if networkResponse.statusCode == 401 {
                                self.popToMainScreen()
                            }else if networkResponse.statusCode == 400 {
                                callback(networkResponse, networkResponse.getError())
                            }else {
                                 callback(nil, networkResponse.getError())
                            }
                        }else {
                            callback(networkResponse, nil)
                        }
                        break
                    }
                case .failure(let error):
                    let networkError = NetworkError(error:error)
                    if networkError.code != 13 {
                        callback(nil, networkError)
                    }
                    break
                }
            }
        }
        else
        {
//            Alert().showAlert(message: "No internet connection")
            callback(nil, NetworkError.init(error: "No internet connection", code: 1))
        }
    }
    func makeRequestURLENcoded(method: HTTPMethod, endPoint: String, params: [String: Any]? = [:], callback: @escaping (NetworkResponse?, NetworkError?) ->()) {
        //  var mutableEndpoint = endPoint
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if reachability.connection != .none
        {
//        accessToken = Storage().readObject(forKey:UserDefault.appToken)!
        
        var headers: HTTPHeaders = [:]
            if (!self.accessToken.isEmpty) {
                headers["Authorization"] =  self.accessToken
            }else {
                let authorizationToken = Storage.shared.readObject(forKey: UserDefault.appToken) ?? ""
                headers["Authorization"] = authorizationToken
            }
            print("Headers = \(headers)")
            print("Request Url = \(Constant.BASE_URL + endPoint)")
        
        AF.request(Constant.BASE_URL + endPoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! , method: method, parameters: params, encoding: URLEncoding.default, headers:  headers ).responseJSON { response in
            switch response.result {
            case .success( _):
                //success, do anything
                if let networkResponse = NetworkResponse(response: response) {
                    print("networkResponse = \(networkResponse.statusCode ?? 0)")
                    if (!networkResponse.isSuccessful()) {
                        print("Response Status Code = \(networkResponse.statusCode ?? 0)")
                        if networkResponse.statusCode == 401 {
                            self.popToMainScreen()
                        }else if networkResponse.statusCode == 400 {
                            callback(networkResponse, networkResponse.getError())
                        }else {
                             callback(nil, networkResponse.getError())
                        }
                    }else {
                        callback(networkResponse, nil)
                    }
                }
                break
            case .failure(let error):
                let networkError = NetworkError(error: error)
                
                print(networkError.code)
                if networkError.code == 4{
                    //callback(nil, NetworkError(error: MessageString.inValidResponseError))
                }else{
                    if networkError.code != 13{
                        callback(nil, networkError)
                    }
                }
                break
            }
        }
        }
        else
        {
            Alert().showAlert(message: "No internet connection")
            callback(nil, NetworkError.init(error: "No internet connection", code: 1))
        }
    }
    
    func makeRequestWithMultipart(method: HTTPMethod, endPoint: String, params: [String: Any]? = [:],imagesData:Data,videoData:Array<Data>?, imageIndex:Int?, imageParam:String, callback: @escaping (NetworkResponse?, NetworkError?) ->()) {
        //  var mutableEndpoint = endPoint
        if reachability.connection != .none
        {
       accessToken = Storage().readObject(forKey:UserDefault.appToken)!

       var headers: HTTPHeaders = [:]
        if (!self.accessToken.isEmpty){
            headers["Authorization"] =  self.accessToken
        }
//        else {
//            let authorizationToken = Storage.shared.readObject(forKey: UserDefault.appToken) ?? ""
//            headers["Authorization"] = authorizationToken
//        }
        print("Headers = \(headers)")
        print("Request Url = \(Constant.BASE_URL + endPoint)")
        print("Parameters = \(params ?? [:])")
        AF.upload(multipartFormData: { multipartFormData in
            // import image to request
//            for index in 0..<imagesData.count
//            {
//                if imagesData[index].count > 0
//                {
                        multipartFormData.append(imagesData, withName: imageParam, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                    if imageIndex != nil
                    {
                        let IndexString: String = String(imageIndex ?? 0)
                        
                        //multipartFormData.append(IndexString.data(using: String.Encoding.utf8)!, withName: "imageName")
                    }
//                }
//            }
            if videoData != nil{
                for vid in videoData! {
                    if vid.count > 0{
                        multipartFormData.append(vid, withName: "video", fileName: "\(Date().timeIntervalSince1970).mp4", mimeType: "video/mp4")
                    }
                }
            }

            for (key, value) in params! {
                let str = String(describing: value)

                multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key )
            }
        }, to: Constant.BASE_URL + endPoint,
           method:method,
           headers:headers)
            .uploadProgress(closure: { (progress) in
                DispatchQueue.main.async {
                    print("Upload Progress: \(progress.fractionCompleted)")
                    let dict: NSMutableDictionary = NSMutableDictionary.init()
                    dict.setValue(progress.fractionCompleted, forKey: "uploadProgress")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SHOWMEDIAUPLOADPROGRESS"), object: nil, userInfo: dict as? [AnyHashable : Any])
                }
            })
            .responseJSON { resp in
                switch resp.result {
                case .success( _):
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let networkResponse = NetworkResponse(response: resp){

                        if (!networkResponse.isSuccessful()) {
                            print("Network response status code  = \(networkResponse.statusCode ?? 0)")
                            if networkResponse.statusCode == 401{
                                self.popToMainScreen()
                            }
                            callback(nil, networkResponse.getError())
                        }else{
                            callback(networkResponse, nil)
                        }
                    }
            case .failure(let error):
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let networkError = NetworkError(error: error)
                if (networkError.message == "Invalid access token"){
                    self.popToMainScreen()
                }
                callback(nil, NetworkError(error: error))
            }
        }
    }
    else
    {
        Alert().showAlert(message: "No internet connection")
        callback(nil, NetworkError.init(error: "No internet connection", code: 1))
    }
    }
    
    
    func makeRequestWithMulti(method: HTTPMethod, endPoint: String, params: [String: Any]? = [:],imagesData:Array<Data>,videoData:Array<Data>?, imageIndex:Int?, imageParam:String, callback: @escaping (NetworkResponse?, NetworkError?) ->()) {
        //  var mutableEndpoint = endPoint
        if reachability.connection != .none
        {
       accessToken = Storage().readObject(forKey:UserDefault.appToken)!

       var headers: HTTPHeaders = [:]
        if (!self.accessToken.isEmpty){
            headers["Authorization"] =  self.accessToken
        }

        AF.upload(multipartFormData: { multipartFormData in
            // import image to request
            for index in 0..<imagesData.count
            {
                if imagesData[index].count > 0
                {
                        multipartFormData.append(imagesData[index], withName: imageParam, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                    if imageIndex != nil
                    {
                        let IndexString: String = String(imageIndex ?? 0)
                        
//                        multipartFormData.append(IndexString.data(using: String.Encoding.utf8)!, withName: "order")
                    }
                }
            }
            if videoData != nil{
                for vid in videoData! {
                    if vid.count > 0{
                        multipartFormData.append(vid, withName: "video", fileName: "\(Date().timeIntervalSince1970).mp4", mimeType: "video/mp4")
                    }
                }
            }
            
            for (key, value) in params! {
                let str = String(describing: value)

                multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key )
            }
        }, to: Constant.BASE_URL + endPoint,
           method:method,
           headers:headers)
            .uploadProgress(closure: { (progress) in
                DispatchQueue.main.async {
                    print("Upload Progress: \(progress.fractionCompleted)")
                    let dict: NSMutableDictionary = NSMutableDictionary.init()
                    dict.setValue(progress.fractionCompleted, forKey: "uploadProgress")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SHOWMEDIAUPLOADPROGRESS"), object: nil, userInfo: dict as? [AnyHashable : Any])
                }
            })
            .responseJSON { resp in
                switch resp.result {
                case .success( _):
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let networkResponse = NetworkResponse(response: resp){

                        if (!networkResponse.isSuccessful()){
                            if networkResponse.statusCode == 401{
                                self.popToMainScreen()
                            }
                            callback(nil, networkResponse.getError())
                        }else{
                            callback(networkResponse, nil)
                        }
                    }
            case .failure(let error):
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let networkError = NetworkError(error: error)
                if (networkError.message == "Invalid access token"){
                    self.popToMainScreen()
                }
                callback(nil, NetworkError(error: error))
            }
        }
    }
    else
    {
        Alert().showAlert(message: "No internet connection")
        callback(nil, NetworkError.init(error: "No internet connection", code: 1))
    }
    }
    
    func makeRequestWithMultipart(method: HTTPMethod, endPoint: String, params: [String: Any]? = [:],imagesData:Array<Data>?,videoData:Array<Data>?,pdf:Data?,imageParam:String, callback: @escaping (NetworkResponse?, NetworkError?) ->()) {
        //  var mutableEndpoint = endPoint

       accessToken = Storage().readObject(forKey:UserDefault.appToken)!

       var headers: HTTPHeaders = [:]
        if (!self.accessToken.isEmpty){
            headers["Authorization"] = accessToken
        }

        AF.upload(multipartFormData: { multipartFormData in
            // import image to request
            if imagesData != nil{
                for index in 0..<imagesData!.count {
                    if imagesData![index].count > 0{
                        multipartFormData.append(imagesData![index], withName: imageParam, fileName: "\(Date().timeIntervalSince1970).png", mimeType: "image/png")
                        
                    }
                }
            }
            if videoData != nil{
                for vid in videoData! {
                    if vid.count > 0{
                        multipartFormData.append(vid, withName: "video", fileName: "\(Date().timeIntervalSince1970).mp4", mimeType: "video/mp4")
                    }
                }
            }
            if pdf != nil{
                multipartFormData.append(pdf!, withName: imageParam, fileName: "\(Date().timeIntervalSince1970).pdf", mimeType: "application/pdf")
            }
            for (key, value) in params! {
                let str = String(describing: value)

                multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key )
            }
        }, to:  Constant.BASE_URL + endPoint,
           method:method,
           headers:headers)
            .responseJSON { resp in
                switch resp.result {
                case .success( _):

                    if let networkResponse = NetworkResponse(response: resp){

                        if (!networkResponse.isSuccessful()){
                            if networkResponse.statusCode == 401{
                                self.popToMainScreen()
                            }
                            callback(nil, networkResponse.getError())
                        }else{
                            callback(networkResponse, nil)
                        }
                    }
            case .failure(let error):
                let networkError = NetworkError(error: error)
                if (networkError.message == "Invalid access token"){
                    self.popToMainScreen()
                }
                callback(nil, NetworkError(error: error))
            }
        }
    }
    
    func popToMainScreen(){
        Storage().clearAllCachedData()
        LocationManager.shared.stopUpdatingLocation()
        Constant.sceneDelegate?.ShowRootViewController()
    }
    
}
