//
//  ChatTVC.swift
//  Phoneado
//
//  Created by Zimble on 4/21/22.
//

import UIKit

class ChatTVC: UITableViewCell {
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var sharedImage: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
