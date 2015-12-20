//
//  SimplifiedItemCell.swift
//  Market
//
//  Created by Dave Vo on 12/15/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class SimplifiedItemCell: UITableViewCell {
    
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
            
            // Set seller
            //      if post.user.objectId != User.currentUser()?.objectId {
            sellerLabel.text = post.user.fullName
            if let avatar = post.user.avatar {
                avatarImageView.alpha = 0.0
                avatarImageView.image = nil
                UIView.animateWithDuration(0.3, animations: {
                    self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                    self.avatarImageView.alpha = 1.0
                })
            } else {
                // load no image
            }
            //      } else {
            //        avatarImageView.hidden = true
            //        sellerLabel.hidden = true
            //      }
            
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
            
            //      let formatter = NSDateFormatter()
            //      formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            //      formatter.dateStyle = NSDateFormatterStyle.MediumStyle
            //      postAtLabel.text = "@ \(formatter.stringFromDate(post.updatedAt!))"
            postAtLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            priceLabel.text = post.price.formatCurrency()
            newTagImageView.hidden = (post.condition > 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemImageView.layer.cornerRadius = 5
        itemImageView.clipsToBounds = true
        priceLabel.layer.cornerRadius = 5
        priceLabel.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}