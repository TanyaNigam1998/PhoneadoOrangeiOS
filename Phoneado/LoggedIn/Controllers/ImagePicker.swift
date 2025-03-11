//
//  ImagePicker.swift
//  Grazzee
//
//  Created by Zimble Code on 29/07/19.
//  Copyright © 2019 IZimble Code. All rights reserved.
//

import UIKit
import CropViewController
import AVFoundation

// @objc public protocol ImagePickerDelegate: class {
//    @objc optional func didSelect(image: UIImage?, data: Data?)
//    @objc optional func cancel(ok:Bool)
//}
//
//open class ImagePicker: NSObject {
//    
//    var cropView:  CropViewController?
//    private let pickerController: UIImagePickerController
//    private weak var presentationController: UIViewController?
//    private weak var delegate: ImagePickerDelegate?
//    var alertController: UIAlertController?
//    
//    var type:String = String()
//    var isCameraOpen:Bool = Bool()
//
//    
//    
//    
//    
//    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
//        self.pickerController = UIImagePickerController()
//        
//        super.init()
//        
//        self.presentationController = presentationController
//        self.delegate = delegate
//        self.pickerController.delegate = self
//        self.pickerController.allowsEditing = false
//        self.pickerController.mediaTypes = ["public.image"]
//    }
//    
//    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
//        guard UIImagePickerController.isSourceTypeAvailable(type) else {
//            return nil
//        }
//        
//        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
//            self.pickerController.sourceType = type
//            self.presentationController?.present(self.pickerController, animated: true)
//        }
//    }
//    
//    public func present(from sourceView: UIView) {
//        if(isCameraOpen) {
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (_) in
//                self.checkCameraAccess()
//            }
//            if self.action(for: .camera, title: "Take photo") != nil {
//                alertController.addAction(cameraAction)
//            }
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
//                self.delegate?.cancel?(ok: true)
//            }))
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                alertController.popoverPresentationController?.sourceView = sourceView
//                alertController.popoverPresentationController?.sourceRect = sourceView.bounds
//                alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
//            }
//            self.presentationController?.present(alertController, animated: true)
//        } else {
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (_) in
//                self.checkCameraAccess()
//            }
//            if self.action(for: .camera, title: "Take photo") != nil {
//                alertController.addAction(cameraAction)
//            }
//            if let action = self.action(for: .photoLibrary, title: "Photo library") {
//                alertController.addAction(action)
//            }
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
//                self.delegate?.cancel?(ok: true)
//            }))
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                alertController.popoverPresentationController?.sourceView = sourceView
//                alertController.popoverPresentationController?.sourceRect = sourceView.bounds
//                alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
//            }
//            self.presentationController?.present(alertController, animated: true)
//        }
//     }
//    
//    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
//        if image != nil {
//           if(type == "picture") {
//                cropView = CropViewController(croppingStyle: .default, image: image!)
//           } else {
//                cropView = CropViewController(croppingStyle: .default, image: image!)
//           }
//            cropView?.delegate = self
//            controller.present(cropView!, animated: true, completion: nil)
//        } else {
//            controller.dismiss(animated: true, completion: nil)
//        }
//        //  controller.dismiss(animated: true, completion: nil)
//        // self.delegate?.didSelect(image: image)
//    }
//    
//    func checkCameraAccess() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .denied:
//            // Utility.showWindowAlert(title: "", message: "Denied, request permission from settings")
//            presentCameraSettings()
//            break
//        case .restricted:
//          //  Utility.showWindowAlert(title: "", message: "Restricted, device owner must approve")
//            break
//        case .authorized:
//            callCamera()
//            break
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { success in
//                if success {
//                    self.callCamera()
//                    //  print("Permission granted, proceed")
//                } else {
//                    self.presentCameraSettings()
//                    //  print("Permission denied")
//                }
//            }
//            break
//        default:
//            print("default")
//            break
//        }
//    }
//    
//    func callCamera() {
//        DispatchQueue.main.async {
//            self.alertController?.dismiss(animated: true, completion: nil)
//            self.presentationController?.view.endEditing(true)
//            if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
//                self.pickerController.sourceType = .camera
//                self.pickerController.showsCameraControls = true
//                self.pickerController.allowsEditing = false
//                self.presentationController?.present(self.pickerController, animated: true, completion: nil)
//            }
//        }
// }
//    func presentCameraSettings() {
//        DispatchQueue.main.async {
//            self.alertController = UIAlertController(title: "Error",
//                                            message: "Camera access is denied",
//                                            preferredStyle: .alert)
//            self.alertController?.addAction(UIAlertAction(title: "Cancel", style: .default))
//            self.alertController?.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
//                    // Handle
//                })
//            }
//        })
//        self.presentationController?.present(self.alertController!, animated: true)
//            
//        }
//    }
//}
//
//extension ImagePicker: UIImagePickerControllerDelegate {
//    
//    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        delegate?.cancel?(ok: true)
//        self.pickerController(picker, didSelect: nil)
//    }
//    
//    public func imagePickerController(_ picker: UIImagePickerController,
//                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        guard let image = info[.originalImage] as? UIImage else {
//            return self.pickerController(picker, didSelect: nil)
//        }
//        
//        
//        self.pickerController(picker, didSelect: image)
//    }
//}
//
//extension ImagePicker: UINavigationControllerDelegate, CropViewControllerDelegate {
//    public func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
//        DispatchQueue.main.async {
//            self.delegate?.cancel?(ok: true)
//            cropViewController.dismiss(animated: true, completion: nil)
//            self.pickerController.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//        delegate?.didSelect?(image: image, data: image.jpegData(compressionQuality: 0.1))
//        cropViewController.dismiss(animated: true, completion: nil)
//        self.pickerController.dismiss(animated: true, completion: nil)
//    }
// }


@objc public protocol ImagePickerDelegate: AnyObject {
    @objc optional func didSelect(image: UIImage?, data: Data?)
    @objc optional func cancel(ok: Bool)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    var alertController: UIAlertController?
    
    var cropView:  CropViewController?
    var type: String = String()
    var isCameraOpen: Bool = Bool()

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if self.isCameraOpen {
            let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (_) in
                self.checkCameraAccess()
            }
            if self.action(for: .camera, title: "Take photo") != nil {
                alertController.addAction(cameraAction)
            }
        } else {
            let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (_) in
                self.checkCameraAccess()
            }
            if self.action(for: .camera, title: "Take photo") != nil {
                alertController.addAction(cameraAction)
            }
            if let action = self.action(for: .photoLibrary, title: "Photo library") {
                alertController.addAction(action)
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.delegate?.cancel?(ok: true)
        }))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        guard let image = image else {
            controller.dismiss(animated: true, completion: nil)
            return
        }

        if controller.sourceType == .camera {
            cropView = CropViewController(croppingStyle: .default, image: image)
            cropView?.delegate = self
            controller.present(cropView!, animated: true, completion: nil)
        } else {
            delegate?.didSelect?(image: image, data: image.jpegData(compressionQuality: 0.1))
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            presentCameraSettings()
        case .restricted:
            break
        case .authorized:
            callCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    self.callCamera()
                } else {
                    self.presentCameraSettings()
                }
            }
        default:
            break
        }
    }
    
    func callCamera() {
        DispatchQueue.main.async {
            self.alertController?.dismiss(animated: true, completion: nil)
            self.presentationController?.view.endEditing(true)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.pickerController.sourceType = .camera
                self.pickerController.showsCameraControls = true
                self.pickerController.allowsEditing = false
                self.presentationController?.present(self.pickerController, animated: true, completion: nil)
            }
        }
    }
    
    func presentCameraSettings() {
        DispatchQueue.main.async {
            self.alertController = UIAlertController(title: "Error",
                                                     message: "Camera access is denied",
                                                     preferredStyle: .alert)
            self.alertController?.addAction(UIAlertAction(title: "Cancel", style: .default))
            self.alertController?.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            self.presentationController?.present(self.alertController!, animated: true)
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.cancel?(ok: true)
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate, CropViewControllerDelegate {
    public func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        DispatchQueue.main.async {
            self.delegate?.cancel?(ok: true)
            cropViewController.dismiss(animated: true, completion: nil)
            self.pickerController.dismiss(animated: true, completion: nil)
        }
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        delegate?.didSelect?(image: image, data: image.jpegData(compressionQuality: 0.1))
        cropViewController.dismiss(animated: true, completion: nil)
        self.pickerController.dismiss(animated: true, completion: nil)
    }
}
