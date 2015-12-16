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
    var clickedButton: Bool = false
    var targetUser1 =  User()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    //Change title of button "unFollowing" <-> "Following"
    @IBAction func onUnFollowingTap(sender: AnyObject) {
        if clickedButton == false {
          self.unfollowingButton.setTitle("Following", forState: .Normal)
          clickedButton = true
            Follow.unfollow(targetUser1, callback: { (success, error: NSError?) -> Void in
                if error == nil {
                    print("UnFollowing successfully", self.targetUser1.fullName)
                } else {
                    print("Can not unfollow \(self.targetUser1.fullName)", error)
                }

          })
          
            
        } else {
           self.unfollowingButton.setTitle("UnFollowing", forState: .Normal)

           clickedButton = false
           Follow.follow(targetUser1, callback: { (success, error: NSError?) -> Void in
                if error == nil {
                    print("Following successfully", self.targetUser1.fullName)
                } else {
                    print("Can not follow \(self.targetUser1.fullName)", error)
                }
            })
        }
    }
    
 
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
