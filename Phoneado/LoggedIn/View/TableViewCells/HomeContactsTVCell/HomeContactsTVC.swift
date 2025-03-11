//
//  HomeContactsTVC.swift
//  Phoneado
//
//  Created by Zimble on 3/28/22.
//

import UIKit

class HomeContactsTVC: UITableViewCell {
    //MARK: - IB Outlets
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImg: UIImageView!
    @IBOutlet weak var contactSelectImg: UIImageView!
    @IBOutlet weak var addToFavouriteContactBtn: cellInfoBtn!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var favoriteImageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contactImg.layer.cornerRadius = contactImg.frame.size.height/2
    }
    
    override func layoutSubviews() {
       super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by:  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
class cellInfoBtn: UIButton {
    var indexPath: IndexPath?
}
