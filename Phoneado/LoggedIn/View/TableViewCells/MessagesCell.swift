//
//  MessagesCell.swift
//  Sitematch
//
//  Created by ZimTej on 5/27/20.
//  Copyright © 2020 ZimbleCode. All rights reserved.
//

import UIKit

class MessagesCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var removeWidth: NSLayoutConstraint!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var unreadCount: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var messagesLbl: UILabel!
    
    @IBOutlet weak var userImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
