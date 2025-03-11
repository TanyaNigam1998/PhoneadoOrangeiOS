//
//  GuestImagePreviewViewController.swift
//  Phoneado
//
//  Created by Apple on 14/07/22.
//

import UIKit
import WebKit

class GuestImageViewController: UIViewController {

  
    @IBOutlet var imageView: UIImageView!
    var celeImg:String = String()
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        self.imageView.sd_setImage(with: URL(string: celeImg), completed: nil)

        // Do any additional setup after loading the view.
    }
}
