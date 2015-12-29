//
//  SearchTableViewCell.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/21/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

protocol NotificationTableViewCellDelegate {
    func notificationTableViewCell(notificationTableViewCell: UITableViewCell, user: User)
}

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeBackgroundView: UIView!
    
    var previousAvatarURL: String?
    var previousPostImageURL: String?
    
    var notification: Notification! {
        didSet {
            let post = notification.post
            notification.fromUser.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                if let avatar = self.notification.fromUser.avatar, urlString = avatar.url where urlString != self.previousAvatarURL  {
//                    self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                    self.previousAvatarURL = urlString
                    let url = NSURL(string: urlString)!
                    self.avatarImageView.alpha = 0
                    
                    self.avatarImageView.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
                        self.avatarImageView.image = image
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.avatarImageView.alpha = 1
                        })
                        }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                            print(error)
                    })
                } else {
                    self.avatarImageView.image = UIImage(named: "profile_blank")
                }
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
            
            itemNameLabel.text = post.title
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
            priceLabel.text = post.price.formatVND()
            newTagImageView.hidden = post.condition > 0
            typeBackgroundView.hidden = false
            switch notification.type {
            case 1:
                typeBackgroundView.backgroundColor = MyColors.greenOfRetweetCount
                typeLabel.text = "Updated"
            case 2:
                typeBackgroundView.backgroundColor = MyColors.purple
                typeLabel.text = "Following"
            case 3:
                typeBackgroundView.backgroundColor = MyColors.bluesky
                typeLabel.text = "Keywords"
            default:
                typeBackgroundView.hidden = true
                typeLabel.text = "???"
            }
            
            if notification.isRead {
                itemNameLabel.font = UIFont.systemFontOfSize(14)
                timeAgoLabel.font = UIFont.systemFontOfSize(12)
                backgroundColor = UIColor.whiteColor()
            } else {
                itemNameLabel.font = UIFont.boldSystemFontOfSize(14)
                timeAgoLabel.font = UIFont.boldSystemFontOfSize(12)
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
        typeBackgroundView.layer.cornerRadius = 5
        typeBackgroundView.clipsToBounds = true
    }
}