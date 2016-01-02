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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isFollowing = true
    var targetUser: User! {
        didSet {
            fullnameLabel.text = targetUser.fullName
            activityIndicator.stopAnimating()
            isFollowing = true
            unfollowingButton.setTitle("Unfollow", forState: .Normal)
            //            cell.unfollowingButton.enabled = false
            //            cell.unfollowingButton.setTitle("", forState: .Normal)
            //            user.didIFollowTheUser { (followed, error) -> Void in
            //                cell.unfollowingButton.enabled = true
            //                cell.activityIndicator.stopAnimating()
            //                cell.unfollowingButton.setTitle(followed ? "Unfollow" : "Follow", forState: .Normal)
            //                cell.isFollowing = followed
            //            }
            
            if let avatarFile = targetUser.avatar {
                avatarFile.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                    self.imgField.image = UIImage(data: data!)
                }
            } else {
                imgField.noAvatar()
            }
        }
    }
    
    override func awakeFromNib() {
        imgField.layer.cornerRadius = imgField.frame.size.width/2
        imgField.clipsToBounds = true
        
        unfollowingButton.layer.cornerRadius = 3
        unfollowingButton.layer.masksToBounds = true
    }
    
    @IBAction func onUnFollowingTap(sender: AnyObject) {
        unfollowingButton.setTitle("", forState: .Normal)
        unfollowingButton.enabled = false
        activityIndicator.startAnimating()
        // unfollow
        if isFollowing {
            Follow.unfollow(targetUser, callback: { (success, error: NSError?) -> Void in
                self.unfollowingButton.enabled = true
                self.activityIndicator.stopAnimating()
                if error == nil {
                    print("Unfollowing successfully", self.targetUser.fullName)
                    self.unfollowingButton.setTitle("Follow", forState: .Normal)
                    self.isFollowing = false
                } else {
                    print("Can not unfollow \(self.targetUser.fullName)", error)
                    self.unfollowingButton.setTitle("Unfollow", forState: .Normal)
                    self.isFollowing = true
                }
            })
        } else {
            Follow.follow(targetUser, callback: { (success, error: NSError?) -> Void in
                self.unfollowingButton.enabled = true
                self.activityIndicator.stopAnimating()
                if error == nil {
                    print("Following successfully", self.targetUser.fullName)
                    self.unfollowingButton.setTitle("Unfollow", forState: .Normal)
                    self.isFollowing = true
                } else {
                    print("Can not follow \(self.targetUser.fullName)", error)
                    self.unfollowingButton.setTitle("Follow", forState: .Normal)
                    self.isFollowing = false
                }
            })
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let buttonBGColor = unfollowingButton.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        unfollowingButton.backgroundColor = buttonBGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let buttonBGColor = unfollowingButton.backgroundColor
        super.setSelected(selected, animated: animated)
        unfollowingButton.backgroundColor = buttonBGColor
    }
}
