//
//  ItemCell.swift
//  Market
//
//  Created by Dave Vo on 12/8/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol ItemCellDelegate {
    optional func itemCell(itemCell: ItemCell, didChangeVote value: Bool, voteCount: Int)
    optional func itemCell(itemCell: ItemCell, didChangeSave value: Bool)
    optional func itemCell(itemCell: ItemCell, tapOnProfile value: Bool)
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    //    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newTagImageView: UIImageView!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var cardView: UIView!
    
    weak var delegate: ItemCellDelegate?
    var previousAvatarURL: String?
    var previousPostImageURL: String?
    
    var item: Post! {
        didSet {
            let post = item
            if let avatar = post.user.avatar, urlString = avatar.url {
                if previousAvatarURL != urlString {
                    previousAvatarURL = urlString
                    avatarImageView.loadAndFadeInWith(urlString, imageViews: nil, duration: 0.5)
                }
            } else {
                avatarImageView.noAvatar()
            }
            
            if post.medias.count > 0 {
                let urlString = post.medias[0].url!
                if previousPostImageURL != urlString {
                    previousPostImageURL = urlString
                    itemImageView.loadAndFadeInWith(urlString, imageViews: [newTagImageView], duration: 0.5)
                }
            }
            
            sellerLabel.text = post.user.fullName
            itemNameLabel.text = post.title
            //            descriptionLabel.text = post.descriptionText
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.createdAt!)
            priceLabel.text = post.price.formatVND()
            newTagImageView.hidden = (post.condition > 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.cornerRadius = 2
        cardView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        cardView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.shadowRadius = 2.0
        
        //        priceLabel.layer.cornerRadius = 2
        //        priceLabel.layer.shadowColor = UIColor.lightGrayColor().CGColor
        //        priceLabel.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        //        priceLabel.layer.shadowOpacity = 1.0
        //        priceLabel.layer.shadowRadius = 2.0
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width/2
        avatarImageView.clipsToBounds = true
        //        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        
        let profileTapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
        profileView.addGestureRecognizer(profileTapGesture)
    }
    
    func tapOnProfile(gesture: UITapGestureRecognizer) {
        self.delegate?.itemCell?(self, tapOnProfile: true)
    }
}
