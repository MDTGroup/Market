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
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    var previousAvatarURL: String?
    var previousPostImageURL: String?
    
    var countMessages: (unread: Int, total: Int)! {
        didSet {
            badgeView.hidden = countMessages.unread == 0
            badgeLabel.text = "\(countMessages.unread)"
            //countMessagesLabel.text = "\(countMessages.unread)/\(countMessages.total)"
        }
    }
    var conversation: Conversation! {
        didSet {
            let post = conversation.post
            
            if let avatar = post.user.avatar, urlString = avatar.url {
                if previousAvatarURL != urlString {
                    previousAvatarURL = urlString
                    let url = NSURL(string: urlString)!
                    
                    avatarImageView.alpha = 0
                    
                    avatarImageView.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
                        self.avatarImageView.image = image
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.avatarImageView.alpha = 1
                        })
                        }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                            print(error)
                    })
                }
            } else {
                self.avatarImageView.image = UIImage(named: "profile_blank")
            }
            
            if post.medias.count > 0 {
//                self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
                if let urlString = post.medias[0].url where previousPostImageURL != urlString {
                    previousPostImageURL = urlString
                    let url = NSURL(string: urlString)!
                    
                    itemImageView.alpha = 0
                    
                    itemImageView.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
                        self.itemImageView.image = image
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.itemImageView.alpha = 1
                        })
                        }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                            print(error)
                    })
                }
            }
            
            self.sellerLabel.text = post.user.fullName
            itemNameLabel.text = post.title
            timeAgoLabel.text = Helper.timeSinceDateToNow(conversation.updatedAt!)
            priceLabel.text = post.price.formatVND()
            newTagImageView.hidden = (post.condition > 0)
            
            if countMessages.unread == 0 {
                itemNameLabel.font = UIFont.systemFontOfSize(14)
                timeAgoLabel.font = UIFont.systemFontOfSize(12)
                sellerLabel.font = UIFont.systemFontOfSize(12)
                backgroundColor = UIColor.whiteColor()
            } else {
                itemNameLabel.font = UIFont.boldSystemFontOfSize(14)
                timeAgoLabel.font = UIFont.boldSystemFontOfSize(12)
                sellerLabel.font = UIFont.boldSystemFontOfSize(12)
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
        badgeView.layer.cornerRadius = 8
        badgeView.clipsToBounds = true
    }
}