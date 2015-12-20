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
    
    var post: Post! {
        didSet {
            self.sellerLabel.text = ""
            post.user.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                if let avatar = self.post.user.avatar {
                    self.avatarImageView.alpha = 0.0
                    UIView.animateWithDuration(0.3, animations: {
                        self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                        self.avatarImageView.alpha = 1.0
                        }, completion: nil)
                }
                self.sellerLabel.text = self.post.user.fullName
            }
            
            // Set Item
            if post.medias.count > 0 {
                itemImageView.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: {
                    self.itemImageView.setImageWithURL(NSURL(string: self.post.medias[0].url!)!)
                    self.itemImageView.alpha = 1.0
                    }, completion: nil)
            }
            
            itemNameLabel.text = post.title
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            priceLabel.text = post.price.formatCurrency()
            newTagImageView.hidden = (post.condition > 0)
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
