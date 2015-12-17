//
//  MessageCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/17/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFullname: UILabel!
    @IBOutlet weak var TimeElapedLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
