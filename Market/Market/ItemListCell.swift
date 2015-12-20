//
//  ItemListCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/18/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import AFNetworking

class ItemListCell: UITableViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var sellerLabel: UILabel!
//    @IBOutlet weak var newTagImageView: UIImageView!
    
    var conversation: Conversation! {
        willSet (newValue) {
            item = newValue.post
        }
    }
    
    var tapGesture: UITapGestureRecognizer!
    
    private var item: Post! {
        didSet {
            let post = item
            // Set seller
//            self.sellerLabel.text = ""
//            if let avatar = post.user.avatar {
//                self.avatarImageView.alpha = 0.0
//                UIView.animateWithDuration(0.3, animations: {
//                    self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
//                    self.avatarImageView.alpha = 1.0
//                    }, completion: nil)
//            } else {
//                // load no image
//            }
            
//            self.sellerLabel.text = post.user.fullName
            
            // Set Item
            if post.medias.count > 0 {
                itemImageView.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: {
                    self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
                    self.itemImageView.alpha = 1.0
                    }, completion: nil)
            } else {
                // Load no image
            }
            itemNameLabel.text = post.title
//            descriptionLabel.text = post.descriptionText
            
            let elapsedTime = NSDate().timeIntervalSinceDate(post.createdAt!)
            var timeSinceCreated = ""
            if elapsedTime < 60 {
                timeSinceCreated = String(Int(elapsedTime)) + "s"
            } else if elapsedTime < 3600 {
                timeSinceCreated = String(Int(elapsedTime / 60)) + "m"
            } else if elapsedTime < 24*3600 {
                timeSinceCreated = String(Int(elapsedTime / 60 / 60)) + "h"
            } else {
                timeSinceCreated = String(Int(elapsedTime / 60 / 60 / 24)) + "d"
            }
            timeAgoLabel.text = timeSinceCreated
            
            priceLabel.text = post.price.formatCurrency()
//            newTagImageView.hidden = (post.condition > 0)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        avatarImageView.layer.cornerRadius = 18
//        avatarImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        
        tapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
//        avatarImageView.addGestureRecognizer(tapGesture)

    }
}