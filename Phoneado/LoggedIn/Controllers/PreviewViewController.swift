//
//  PreviewViewController.swift
//  Phoneado
//
//  Created by Apple on 13/07/22.
//

import UIKit
import SDWebImage
class PreviewViewController: UIViewController {
    
    var image: UIImage = UIImage()
    var url:String = String()
    var fromChatVC: Bool = false
    @IBOutlet var imageScrollView: ImageScrollView!
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        if fromChatVC {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Constant.appDelegate.showProgressHUD(view: self.view)
        imageScrollView.setup()
        
        if (url != "") {
            SDWebImageManager.shared.loadImage(with:URL(string: url), options: .highPriority,progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                if image != nil{
                    let imageData: UIImage = UIImage(data:image!.pngData()!)!
                    self.imageScrollView.display(image:imageData)
                    self.imageScrollView.imageScrollViewDelegate = self
                }
            }
            Constant.appDelegate.hideProgressHUD()
        } else {
            DispatchQueue.global(qos: .background).async { [self] in
                do {
                    DispatchQueue.main.async { [self] in
                        self.imageScrollView.display(image:image)
                        self.imageScrollView.imageScrollViewDelegate = self
                    }
                }
                catch {
                    print("Error====>", error.localizedDescription)
                }
            }
            Constant.appDelegate.hideProgressHUD()
        }
    }
}


extension PreviewViewController: ImageScrollViewDelegate {
            func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
                print("Did change orientation")
            }
            
            func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
                print("scrollViewDidEndZooming at scale \(scale)")
            }
            
            func scrollViewDidScroll(_ scrollView: UIScrollView) {
                print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
            }
}
