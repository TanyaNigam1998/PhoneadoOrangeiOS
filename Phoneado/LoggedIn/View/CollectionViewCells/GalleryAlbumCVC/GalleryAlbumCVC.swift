//
//  GalleryAlbumCVC.swift
//  Phoneado
//
//  Created by Zimble on 3/28/22.
//

import UIKit

class GalleryAlbumCVC: UICollectionViewCell {
    //MARK: - IB Outlets
    @IBOutlet weak var albumTitleLbl:UILabel!
    @IBOutlet weak var albumImageCountLbl: UILabel!
    @IBOutlet weak var albumThumbnailImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
