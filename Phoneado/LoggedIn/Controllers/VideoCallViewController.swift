//
//  VideoCallViewController.swift
//  Phoneado
//
//  Created by Apple on 17/05/22.
//

import UIKit
import TwilioVideo
import CallKit

class VideoCallViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func VideoControllActions(sender: UIButton)
    {
        
    }
    
}
