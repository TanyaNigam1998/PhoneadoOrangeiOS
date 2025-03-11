//
//  UIViewController+Extension.swift
//  Quicklyn
//
//  Created by Zimble on 12/2/21.
//

import Foundation
import UIKit

enum PushAnimationType{
    case animateFromRight
    case animateFromLeft
    case animateFromUp
    case animateFromDown
}

extension UIViewController {
    
    static var topMostViewController : UIViewController {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    {
            return UIViewController.topViewController(rootViewController: window.rootViewController!)
        }
        else {
            return UIViewController()
        }
    }
    
    fileprivate static func topViewController(rootViewController: UIViewController) -> UIViewController {
        guard rootViewController.presentedViewController != nil else {
            if rootViewController is UITabBarController {
                let tabbarVC = rootViewController as! UITabBarController
                let selectedViewController = tabbarVC.selectedViewController
                return UIViewController.topViewController(rootViewController: selectedViewController!)
            }
                
            else if rootViewController is UINavigationController {
                let navVC = rootViewController as! UINavigationController
                if navVC.viewControllers.count == 0 {
                    return navVC
                }
                return UIViewController.topViewController(rootViewController: navVC.viewControllers.last!)
            }
            
            return rootViewController
        }
        
        return topViewController(rootViewController: rootViewController.presentedViewController!)
    }
    
    //MARK:- changeRootViewControllerWithPushanimation
    func showViewControllerWith(newViewController:UIViewController, usingAnimation animationType:PushAnimationType)
    {
        if #available(iOS 13.0, *) {
            UIApplication.shared.delegate?.window??.rootViewController = newViewController
            return
        }
        
        if let currentViewController = UIApplication.shared.delegate?.window??.rootViewController {
            let width = currentViewController.view.frame.size.width;
            let height = currentViewController.view.frame.size.height;
            
            var previousFrame: CGRect?
            var nextFrame: CGRect?
            
            switch animationType
            {
            case .animateFromLeft:
                previousFrame = CGRect(x: width - 1, y: 0.0, width: width, height: height)
                nextFrame = CGRect(x: -width * 0.3, y: 0.0, width: width, height: height)
            case .animateFromRight:
                previousFrame = CGRect(x: -width + 1, y: 0.0, width: width, height: height)
                nextFrame = CGRect(x: width * 0.3, y: 0.0, width: width, height: height)
            case .animateFromUp:
                previousFrame = CGRect(x: 0.0, y: height - 1.0, width: width, height: height)
                nextFrame = CGRect(x: 0.0, y: -height + 1, width: width, height: height)
            case .animateFromDown:
                previousFrame = CGRect(x: 0.0, y: -height + 1.0, width: width, height: height)
                nextFrame = CGRect(x: 0.0, y: height - 1, width: width, height: height)
            }
            
            newViewController.view.frame = previousFrame!
            UIApplication.shared.delegate?.window??.addSubview(newViewController.view)
            UIView.animate(withDuration: 0.33, animations: {
                newViewController.view.frame = currentViewController.view.frame
                currentViewController.view.frame = nextFrame!
            }, completion: { (fihish) in
                UIApplication.shared.delegate?.window??.rootViewController = newViewController
            })
        }
    }
}

extension UIViewController {
    
    class func loadViewController(withStoryBoard storyBoardName: StoryBoardName) -> Self {
        return instantiateViewController(withStoryBoard: storyBoardName.rawValue)
    }
    
    private class func instantiateViewController<T>(withStoryBoard storyBoardName: String) -> T{
        let sb: UIStoryboard = UIStoryboard(name: storyBoardName, bundle: nil)
        let controller  = sb.instantiateViewController(withIdentifier: String(describing: self)) as! T
        return controller
    }
    
    static func instantiateFromNib<T: UIViewController>(xibName: String? = nil) -> T {
        return T(nibName: xibName ?? String(describing: self), bundle: Bundle(for: self))
    }
    
}
