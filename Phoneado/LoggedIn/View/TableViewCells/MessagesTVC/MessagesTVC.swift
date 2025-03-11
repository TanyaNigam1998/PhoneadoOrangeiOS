//
//  MessagesTVC.swift
//  Phoneado
//
//  Created by Zimble on 3/30/22.
//

import UIKit

class MessagesTVC: UITableViewCell {
    //MARK: - IB Outlets
    @IBOutlet weak var contactImgView: UIImageView!
    @IBOutlet weak var contactNameLbl: UILabel!
    @IBOutlet weak var contactMessageLbl: UILabel!
    @IBOutlet weak var isReadVIew: UIView!
    @IBOutlet weak var messageTimeLbl: UILabel!
    
    @IBOutlet var countLbl: UILabel!
    //MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contactImgView.layer.cornerRadius = self.contactImgView.frame.size.height/2
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
