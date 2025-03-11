//
//  BaseViewController.swift
//  Phoneado
//
//  Created by Zimble on 3/25/22.
//

import Foundation
import UIKit

enum LeftSideButton: Int{
    case back, menu
    
    var getImage: UIImage?{
        if (self == LeftSideButton.back) {return UIImage.init(named: "close")}
        else if (self == LeftSideButton.menu) {return UIImage.init(named: "showOrange")}
        return UIImage()
    }
}

enum RightSideButton: Int{
    case close
    
    var getImage: UIImage?{
        if (self == RightSideButton.close) {return UIImage.init(named: "close")}
        return UIImage()
    }
}

class BaseViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var arrLeftSideButton: [LeftSideButton] = []
    var arrRightSideButton: [RightSideButton] = []
 //   let noResultfooter = UINib(nibName: "noResultFooter", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? NoResultFooter
    let imagePickerController = UIImagePickerController()
    var completitionClosure: ((UIImage) -> Void)?
    var docCompletitionClosure: ((URL) -> Void)?

    var completition: ((UIEdgeInsets) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    func setUpTitle(_ title: String, textColor color:UIColor = UIColor.black) -> Void {
        let titleLabel = UILabel.init()
        titleLabel.text = title
        titleLabel.textColor = color
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    
    func setUpLeftbarButtonArray(){
        guard let navVC = self.navigationController else {return}
        if navVC.viewControllers.count > 1 {
            self.arrLeftSideButton = [LeftSideButton.back]
        }
    }
    
    func setUpRightbarButtonArray(){
        guard let navVC = self.navigationController else {return}
        if navVC.viewControllers.count > 1 {
            self.arrRightSideButton = [RightSideButton.close]
        }
    }
    
    func createLeftBarButton(){
        guard let navVC = self.navigationController else {return}
        
        var arrbarButton: [UIBarButtonItem] = []
        for type in self.arrLeftSideButton{
            let button = UIButton.init(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setImage(type.getImage, for: .normal)
            button.tag = type.rawValue
            button.sizeToFit()
            button.contentHorizontalAlignment = .left
            button.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
            arrbarButton.append(UIBarButtonItem.init(customView: button))
        }
        navVC.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = arrbarButton
    }
    
    func createRightBarButton(){
        guard let navVC = self.navigationController else {return}
        
        var arrbarButton: [UIBarButtonItem] = []
        for type in self.arrRightSideButton{
            let button = UIButton.init(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setImage(type.getImage, for: .normal)
            button.tag = type.rawValue
            button.sizeToFit()
            button.contentHorizontalAlignment = .right
            button.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
            arrbarButton.append(UIBarButtonItem.init(customView: button))
        }
        navVC.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = arrbarButton
    }
    
    @objc func leftButtonAction(_ sender: UIButton){
        guard let navVC = self.navigationController else {return}
        if let buttonType = LeftSideButton.init(rawValue: sender.tag)
        {
            if buttonType == LeftSideButton.back {
                navVC.popViewController(animated: true)
            }
        }
    }
    @objc func rightButtonAction(_ sender: UIButton){
        
    }
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let completitionClosure = completitionClosure, let image =  info[.editedImage] as? UIImage{
            
            completitionClosure(image)
        }
        
        imagePickerController.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true)
    }
    func setupImagePicker(vc:UIViewController,completitionHandler:((UIImage) -> Void)?,docHandler:((URL) -> Void)? = nil) {
        self.imagePickerController.delegate = self
        self.completitionClosure = completitionHandler
        self.imagePickerController.allowsEditing = true
        let alertView = UIAlertController(title: "Select Method", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.imagePickerController.sourceType = .camera
            vc.present(self.imagePickerController, animated: true, completion: nil)
        })
        let action1 = UIAlertAction(title: "Gallery", style: .default, handler: { (alert) in
            self.imagePickerController.sourceType = .photoLibrary
            vc.present(self.imagePickerController, animated: true, completion: nil)
        })
        let action2 = UIAlertAction(title: "Document(Pdf)", style: .default, handler: { (alert) in
            })
        let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in })
        if docHandler != nil{
            alertView.addAction(action2)
            alertView.addAction(action3)
        } else {
            alertView.addAction(action)
            alertView.addAction(action1)
            alertView.addAction(action3)
        }
        vc.present(alertView, animated: true, completion: nil)
    }
}

extension BaseViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
