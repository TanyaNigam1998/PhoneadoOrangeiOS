//
//  UserCallLogsTVC.swift
//  Phoneado
//
//  Created by Shobhit Dhuria on 11/07/23.
//

import UIKit

class UserCallLogsTVC: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var voiceVideoImageView: UIImageView!
    @IBOutlet weak var incomingOutgoingCallLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
