//
//  FollowingTableViewCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class FollowingTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgField: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var unfollowingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
