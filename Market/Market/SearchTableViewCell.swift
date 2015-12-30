//
//  SearchTableViewCell.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/21/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newTagImageView: UIImageView!
    
    var previousAvatarURL: String?
    var previousPostImageURL: String?
    
    var post: Post! {
        didSet {
            self.sellerLabel.text = ""
            post.user.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                if let avatar = self.post.user.avatar, urlString = avatar.url {
                    if urlString != self.previousAvatarURL {
                        self.previousAvatarURL = urlString
                        self.avatarImageView.loadAndFadeInWith(urlString, imageViews: nil, duration: 0.5)
                    }
                } else {
                    self.avatarImageView.noAvatar()
                }
                self.sellerLabel.text = self.post.user.fullName
            }
            
            // Set Item
            if post.medias.count > 0 {
                let urlString = self.post.medias[0].url!
                if urlString != previousPostImageURL {
                    previousPostImageURL = urlString
                    itemImageView.loadAndFadeInWith(urlString, imageViews: [newTagImageView], duration: 0.5)
                }
            }
            
            itemNameLabel.text = post.title
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            priceLabel.text = post.price.formatVND()
            newTagImageView.hidden = (post.condition > 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
    }
}
