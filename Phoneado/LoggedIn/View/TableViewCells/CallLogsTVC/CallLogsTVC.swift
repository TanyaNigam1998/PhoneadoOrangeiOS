//
//  CallLogsTVC.swift
//  Phoneado
//
//  Created by Shobhit Dhuria on 05/07/23.
//

import UIKit

class CallLogsTVC: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var incomingOrOutgoingLbl: UILabel!
    @IBOutlet weak var dialVideoCallImageView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
