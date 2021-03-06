//
//  SimplifiedItemCell.swift
//  Market
//
//  Created by Dave Vo on 12/15/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SimplifiedItemCell: MGSwipeTableCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var postAtLabel: UILabel!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var soldView: UIView!
    
    var profileId: String?
    var previousAvatarURL: String?
    var previousPostImageURL: String?
    
    var item: Post! {
        didSet {
            let post = item
            sellerLabel.text = post.user.fullName
            if let avatar = post.user.avatar, urlString = avatar.url {
                if urlString != previousAvatarURL {
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
            itemNameLabel.text = post.title
            postAtLabel.text = Helper.timeSinceDateToNow(post.createdAt!)
            newTagImageView.hidden = (post.condition > 0)
            priceLabel.text = post.price.formatVND()
            soldView.hidden = !post.sold
            
            if let profileId = profileId where profileId == post.user.objectId {
                avatarImageView.hidden =  true
                sellerLabel.hidden = true
            } else {
                avatarImageView.hidden =  false
                sellerLabel.hidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemImageView.layer.cornerRadius = 5
        itemImageView.clipsToBounds = true
        soldView.layer.cornerRadius = 5
        soldView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let soldViewBGColor = soldView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        soldView.backgroundColor = soldViewBGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let soldViewBGColor = soldView.backgroundColor
        super.setSelected(selected, animated: animated)
        soldView.backgroundColor = soldViewBGColor
    }
}