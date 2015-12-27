//
//  SearchTableViewCell.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/21/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

protocol NotificationTableViewCellDelegate {
    func notificationTableViewCell(notificationTableViewCell: UITableViewCell, user: User)
}

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeBackgroundView: UIView!
    
    var notification: Notification! {
        didSet {
            let post = notification.post
            notification.fromUser.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                if let avatar = self.notification.fromUser.avatar {
                    self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                } else {
                    self.avatarImageView.image = UIImage(named: "profile_blank")
                }
            }
            
            if post.medias.count > 0 {
                self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
            }
            
            itemNameLabel.text = post.title
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            priceLabel.text = post.price.formatVND()
            newTagImageView.hidden = post.condition > 0
            typeBackgroundView.hidden = false
            switch notification.type {
            case 1:
                typeBackgroundView.backgroundColor = MyColors.greenOfRetweetCount
                typeLabel.text = "Updated"
            case 2:
                typeBackgroundView.backgroundColor = MyColors.purple
                typeLabel.text = "Following"
            case 3:
                typeBackgroundView.backgroundColor = MyColors.bluesky
                typeLabel.text = "Keywords"
            default:
                typeBackgroundView.hidden = true
                typeLabel.text = "???"
            }
            
            if notification.isRead {
                itemNameLabel.font = UIFont.systemFontOfSize(14)
                timeAgoLabel.font = UIFont.systemFontOfSize(12)
                priceLabel.font = UIFont.systemFontOfSize(12)
                backgroundColor = UIColor.whiteColor()
            } else {
                itemNameLabel.font = UIFont.boldSystemFontOfSize(14)
                timeAgoLabel.font = UIFont.boldSystemFontOfSize(12)
                priceLabel.font = UIFont.boldSystemFontOfSize(12)
                backgroundColor = MyColors.highlightForNotification
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        typeBackgroundView.layer.cornerRadius = 5
        typeBackgroundView.clipsToBounds = true
    }
}