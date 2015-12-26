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
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var countMessagesLabel: UILabel!
    
    var countMessages: (unread: Int, total: Int)! {
        didSet {
            countMessagesLabel.text = "\(countMessages.unread)/\(countMessages.total)"
        }
    }
    var conversation: Conversation! {
        didSet {
            let post = conversation.post
            
            self.sellerLabel.text = ""
            if let avatar = post.user.avatar, url = avatar.url {
                self.avatarImageView.setImageWithURL(NSURL(string: url)!)
                self.sellerLabel.text = post.user.fullName
            }
            
            if post.medias.count > 0 {
                self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
            }
            
            itemNameLabel.text = post.title
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.createdAt!)
            priceLabel.text = post.price.formatVND()
            newTagImageView.hidden = (post.condition > 0)
            
            if countMessages.unread == 0 {
                itemNameLabel.font = UIFont.systemFontOfSize(14)
                timeAgoLabel.font = UIFont.systemFontOfSize(12)
                sellerLabel.font = UIFont.systemFontOfSize(12)
                countMessagesLabel.font = UIFont.systemFontOfSize(12)
                backgroundColor = UIColor.whiteColor()
            } else {
                itemNameLabel.font = UIFont.boldSystemFontOfSize(14)
                timeAgoLabel.font = UIFont.boldSystemFontOfSize(12)
                sellerLabel.font = UIFont.boldSystemFontOfSize(12)
                countMessagesLabel.font = UIFont.boldSystemFontOfSize(12)
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
    }
}