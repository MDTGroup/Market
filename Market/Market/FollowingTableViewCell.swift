//
//  FollowingTableViewCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

@objc protocol FollowingTableViewCellDelegate {
    optional func followingTableViewCell(followingTableViewCell: FollowingTableViewCell, didUnfollow value: Bool)
}

class FollowingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgField: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var unfollowingButton: UIButton!
    var clickedButton: Bool = false
    var targetUser =  User()
    
    weak var delegate: FollowingTableViewCellDelegate?
    
    override func awakeFromNib() {
        imgField.layer.cornerRadius = imgField.frame.size.width/2
        imgField.clipsToBounds = true
    }
    
    @IBAction func onUnFollowingTap(sender: AnyObject) {
        Follow.unfollow(targetUser, callback: { (success, error: NSError?) -> Void in
            if error == nil {
                print("UnFollowing successfully", self.targetUser.fullName)
                self.delegate?.followingTableViewCell!(self, didUnfollow: true)
            } else {
                print("Can't unfollow \(self.targetUser.fullName)", error)
            }
        })
        
        //Change title of button "unFollowing" <-> "Following"
        //        if clickedButton == false {
        //            self.unfollowingButton.setTitle("Following", forState: .Normal)
        //            clickedButton = true
        //            Follow.unfollow(targetUser, callback: { (success, error: NSError?) -> Void in
        //                if error == nil {
        //                    print("UnFollowing successfully", self.targetUser.fullName)
        //                } else {
        //                    print("Can not unfollow \(self.targetUser.fullName)", error)
        //                }
        //            })
        //        } else {
        //            self.unfollowingButton.setTitle("UnFollowing", forState: .Normal)
        //            
        //            clickedButton = false
        //            Follow.follow(targetUser, callback: { (success, error: NSError?) -> Void in
        //                if error == nil {
        //                    print("Following successfully", self.targetUser.fullName)
        //                } else {
        //                    print("Can not follow \(self.targetUser.fullName)", error)
        //                }
        //            })
        //        }
    }
}
