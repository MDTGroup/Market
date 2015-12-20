//
//  SearchTableViewCell.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/21/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var type: UILabel!
    
    var notification: Notification! {
        didSet {
            let post = notification.post
            self.sellerLabel.text = ""
            notification.fromUser.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                if let avatar = self.notification.fromUser.avatar {
                    self.avatarImageView.alpha = 0.0
                    UIView.animateWithDuration(0.3, animations: {
                        self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                        self.avatarImageView.alpha = 1.0
                        }, completion: nil)
                }
                self.sellerLabel.text = self.notification.fromUser.fullName
            }
            
            // Set Item
            if post.medias.count > 0 {
                itemImageView.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: {
                    self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
                    self.itemImageView.alpha = 1.0
                    }, completion: nil)
            }
            
            itemNameLabel.text = post.title
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            priceLabel.text = post.price.formatCurrency()
            newTagImageView.hidden = (post.condition > 0)
            type.text = NotificationType.fromInt(notification.type)
        }
    }
    
    var tapGesture: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        tapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    func tapOnProfile(gesture: UITapGestureRecognizer) {
        //        self.delegate?.itemListCell?(self, tapOnProfile: true)
    }
}