//
//  SimplifiedItemCell.swift
//  Market
//
//  Created by Dave Vo on 12/15/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import SWTableViewCell

class SimplifiedItemCell: SWTableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var postAtLabel: UILabel!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var sellerLabel: UILabel!
    
    var item: Post! {
        didSet {
            let post = item
            sellerLabel.text = post.user.fullName
            if let avatar = post.user.avatar {
                avatarImageView.alpha = 0.0
                avatarImageView.image = nil
                UIView.animateWithDuration(0.3, animations: {
                    self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                    self.avatarImageView.alpha = 1.0
                })
            }
            if post.medias.count > 0 {
                itemImageView.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: {
                    self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
                    self.itemImageView.alpha = 1.0
                    }, completion: nil)
            }
            itemNameLabel.text = post.title
            postAtLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            newTagImageView.hidden = (post.condition > 0)
            
            if post.sold {
                priceLabel.text = "SOLD"
                priceLabel.backgroundColor = MyColors.carrot
                priceLabel.textColor = UIColor.whiteColor()
            } else {
                priceLabel.text = post.price.formatVND()
                priceLabel.backgroundColor = UIColor.whiteColor()
                priceLabel.textColor = MyColors.green
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemImageView.layer.cornerRadius = 5
        itemImageView.clipsToBounds = true
        priceLabel.layer.cornerRadius = 5
        priceLabel.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
    }
}