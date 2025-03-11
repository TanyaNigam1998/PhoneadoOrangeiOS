//
//  MainMenuTVC.swift
//  Phoneado
//
//  Created by Apple on 17/05/22.
//

import UIKit

class MainMenuTVC: UITableViewCell {

    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageVIew: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
