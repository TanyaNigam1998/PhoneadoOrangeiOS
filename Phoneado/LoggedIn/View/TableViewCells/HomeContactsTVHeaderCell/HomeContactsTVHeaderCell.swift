//
//  HomeContactsTVHeaderCell.swift
//  Phoneado
//
//  Created by Zimble on 3/25/22.
//

import UIKit

class HomeContactsTVHeaderCell: UITableViewCell {
    //MARK: - IB Outlets
    @IBOutlet weak var alphabetsLbl: UILabel!
    @IBOutlet weak var selectAllImgView: UIImageView!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var selectAllLbl: UILabel!
    @IBOutlet weak var selectAllSelectionView: UIView!
    @IBOutlet weak var selectAllSelectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectAllStackView: UIStackView!
    //MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
