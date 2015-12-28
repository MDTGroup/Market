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
    var targetUser: User!
    
    override func awakeFromNib() {
        imgField.layer.cornerRadius = imgField.frame.size.width/2
        imgField.clipsToBounds = true
        
        unfollowingButton.layer.cornerRadius = 8
        unfollowingButton.layer.masksToBounds = true
        unfollowingButton.layer.borderWidth = 1
        unfollowingButton.layer.borderColor = MyColors.green.CGColor
    }
    
    @IBAction func onUnFollowingTap(sender: AnyObject) {
        //Change title of button "unFollowing" <-> "Following"
        if clickedButton == false {
            self.unfollowingButton.setTitle("Follow", forState: .Normal)
            clickedButton = true
            Follow.unfollow(targetUser, callback: { (success, error: NSError?) -> Void in
                if error == nil {
                    print("Unfollowing successfully", self.targetUser.fullName)
                } else {
                    print("Can not unfollow \(self.targetUser.fullName)", error)
                }
            })
        } else {
            self.unfollowingButton.setTitle("Unfollow", forState: .Normal)
            
            clickedButton = false
            Follow.follow(targetUser, callback: { (success, error: NSError?) -> Void in
                if error == nil {
                    print("Following successfully", self.targetUser.fullName)
                } else {
                    print("Can not follow \(self.targetUser.fullName)", error)
                }
            })
        }
    }
}
