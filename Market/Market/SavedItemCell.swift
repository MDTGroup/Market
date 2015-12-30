//
//  SavedItemCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/17/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol SavedItemCellDelegate {
    optional func savedItemCell(tweetCell: SavedItemCell, didChangeVote value: Bool)
    optional func savedItemCell(tweetCell: SavedItemCell, didChangeSave value: Bool)
    optional func savedItemCell(SavedItemCell: SavedItemCell, tapOnProfile value: Bool)
}

class SavedItemCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var newTagImageView: UIImageView!
    
    weak var delegate: SavedItemCellDelegate?
    
    var tapGesture: UITapGestureRecognizer!
    var previousAvatarURL: String?
    var previousPostImageURL: String?

    var item: Post! {
        didSet {
            let post = item
            // Set seller
            self.sellerLabel.text = ""
            if let avatar = post.user.avatar, urlString = avatar.url {
                if urlString != previousAvatarURL {
                    previousAvatarURL = urlString
                    avatarImageView.loadAndFadeInWith(urlString, imageViews: nil, duration: 0.5)
                }
            } else {
               avatarImageView.noAvatar()
            }
            
            self.sellerLabel.text = post.user.fullName
            
            // Set Item
            if post.medias.count > 0 {
                let urlString = post.medias[0].url!
                if urlString != previousPostImageURL {
                    previousPostImageURL = urlString
                    itemImageView.loadAndFadeInWith(urlString, imageViews: [newTagImageView], duration: 0.5)
                }
            }
            itemNameLabel.text = post.title
            descriptionLabel.text = post.descriptionText

            timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            
            priceLabel.text = post.price.formatCurrency()
            newTagImageView.hidden = (post.condition > 0)
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        
        tapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
        avatarImageView.addGestureRecognizer(tapGesture)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onVoteChanged(sender: UIButton) {
        if sender.imageView?.image == UIImage(named: "thumb") {
            // Un-vote it
            sender.setImage(UIImage(named: "thumb_gray"), forState: .Normal)
            self.delegate?.savedItemCell?(self, didChangeVote: false)
            
        } else {
            // Vote it
            sender.setImage(UIImage(named: "thumb"), forState: .Normal)
            self.delegate?.savedItemCell?(self, didChangeVote: true)
        }
    }
    
    @IBAction func onSaveChanged(sender: UIButton) {
        if sender.imageView?.image == UIImage(named: "save") {
            // Un-vote it
            sender.setImage(UIImage(named: "save_gray"), forState: .Normal)
            self.delegate?.savedItemCell?(self, didChangeSave: false)
            
        } else {
            // Vote it
            sender.setImage(UIImage(named: "save"), forState: .Normal)
            self.delegate?.savedItemCell?(self, didChangeSave: true)
        }
    }
    func tapOnProfile(gesture: UITapGestureRecognizer) {
        print("i tap on profile pic")
        self.delegate?.savedItemCell?(self, tapOnProfile: true)
    }

}
