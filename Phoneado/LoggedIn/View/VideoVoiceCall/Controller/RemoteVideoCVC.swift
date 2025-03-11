//
//  RemoteVideoCVC.swift
//  Phoneado
//
//  Created by Tanya Nigam on 26/02/25.
//

import UIKit
import TwilioVideo

class RemoteVideoCVC: UICollectionViewCell {
    //MARK: - IBOutlet
    @IBOutlet weak var videoView: VideoView!
    
    //MARK: - Variables
    var localRenderer: LocalVideoTrack?
    var remoteRenderer: RemoteVideoTrack?
    var isLocal: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if isLocal {
            localRenderer?.removeRenderer(videoView)
        } else {
            remoteRenderer?.removeRenderer(videoView)
        }
    }
}
