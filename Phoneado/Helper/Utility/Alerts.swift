//
//  Alerts.swift
//  Quicklyn
//
//  Created by Zimble on 12/6/21.
//

import Foundation
import UIKit

//MARK: ALERT ATTRIBUTS
struct AlertAttributes {
    static let titleTextColor = "titleTextColor"
    static let attributedTitle = "attributedTitle"
    static let attributedMessage = "attributedMessage"
}

func alertWith(title: String, message: String, controller: UIViewController){
   
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
   
    let action = UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default) { (_) in
        
    }

    alert.addAction(action)

    DispatchQueue.main.async {
        controller.present(alert, animated: true, completion: nil)
    }
}

import UIKit
class Alert: NSObject {
    static let shared = Alert()
    
    func showActionSheet( title: String?,  message: String, buttonStyle:UIAlertAction.Style = .default , withVC vc: UIViewController,  buttonTitle:String,secondBtnTitle:String, withCallback callback:@escaping () -> Void, withCancelCallback cancel:@escaping () -> Void ){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: buttonTitle, style: buttonStyle, handler: {(_ action: UIAlertAction) -> Void in
            callback()
        })
        alert.addAction(ok)
        if !secondBtnTitle.isEmpty{
            alert .addAction(UIAlertAction(title: secondBtnTitle, style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
                cancel()
            }))
        }
        
        alert .addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            
        }))
        
        vc.present(alert, animated: true) {() -> Void in }
    }
    
    func showAlertWithAction( title: String,  message: String, buttonStyle:UIAlertAction.Style = .default , withVC vc: UIViewController? = nil,  buttonTitle:String,secondBtnTitle:String, withCallback callback:@escaping () -> Void, withCancelCallback cancel:@escaping () -> Void ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: buttonTitle, style: buttonStyle, handler: {(_ action: UIAlertAction) -> Void in
            callback()
        })
        if !secondBtnTitle.isEmpty{
            alert .addAction(UIAlertAction(title: secondBtnTitle, style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                cancel()
            }))
        }
        
        alert.addAction(ok)
        if vc != nil{
            vc!.present(alert, animated: true) {() -> Void in }
        }else{
            UIApplication.getTopViewController()?.present(alert, animated: true) {() -> Void in }
        }
    }
    
    func showAlert(message: String, title: String = TextString.alert, preferredStyle: UIAlertController.Style = .alert){
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let defaultAction = UIAlertAction(title: TextString.ok, style: .default, handler: nil)
        alert.addAction(defaultAction)
        UIApplication.getTopViewController()?.present(alert, animated: true, completion: nil)
    }
    
//     Please note at a time only one destructive allowed by default
    internal class func displayActionsheet (viewController: UIViewController = UIViewController.topMostViewController, title: String? = nil, message: String?, buttonTitle arrbtn:[String], CompletionHandler comp:((_ index: Int) -> Void)? = nil) {

        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        for strTitle in arrbtn {
            var alertActionStyle = UIAlertAction.Style.default

            if strTitle.lowercased()  == "cancel" {
                alertActionStyle = .cancel
            }
            else if strTitle.lowercased() == "delete" {
                alertActionStyle = .destructive
            }

            let alertAction = UIAlertAction(title: strTitle, style: alertActionStyle, handler: { (action) in
                if let completion = comp, let title = action.title, let index = arrbtn.firstIndex(of: title) {
                    completion(index)
                }
            })
            alertAction.setValue(UIColor.blue, forKey: AlertAttributes.titleTextColor)
            alertVC.addAction(alertAction)
        }
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    internal class func displayActionsheetWithoutTitle (viewController: UIViewController = UIViewController.topMostViewController, title: String? = nil, message: String?, buttonTitle arrbtn:[String], CompletionHandler comp:((_ index: Int) -> Void)? = nil) {

        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for strTitle in arrbtn {
            var alertActionStyle = UIAlertAction.Style.default

            if strTitle.lowercased()  == "cancel" {
                alertActionStyle = .cancel
            }
            else if strTitle.lowercased() == "delete" {
                alertActionStyle = .destructive
            }

            let alertAction = UIAlertAction(title: strTitle, style: alertActionStyle, handler: { (action) in
                if let completion = comp, let title = action.title, let index = arrbtn.firstIndex(of: title) {
                    completion(index)
                }
            })
            alertAction.setValue(UIColor.alertButtonColor, forKey: AlertAttributes.titleTextColor)
            alertVC.addAction(alertAction)
        }
        viewController.present(alertVC, animated: true, completion: nil)
    }
}
    
extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
