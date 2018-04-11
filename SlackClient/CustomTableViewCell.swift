//
//  CustomTableViewCell.swift
//  SlackClient
//
//  Created by Azuma on 2017/09/07.
//  Copyright © 2017年 Azuma. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var user_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class ChannelViewCell: UITableViewCell {
    
    @IBOutlet weak var channel_name: UILabel!
    
}
