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
    @IBOutlet weak var soldView: UIView!
    
    var profileId: String?
    var previousAvatarURL: String?
    var previousPostImageURL: String?
    
    var item: Post! {
        didSet {
            let post = item
            sellerLabel.text = post.user.fullName
            if let avatar = post.user.avatar, urlString = avatar.url where urlString != previousAvatarURL {
                previousAvatarURL = urlString
                let url = NSURL(string: urlString)!
                avatarImageView.alpha = 0
                avatarImageView.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
                    self.avatarImageView.image =  image
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.avatarImageView.alpha = 1
                    })
                    }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                        print(error)
                })
            } else {
                avatarImageView.image = UIImage(named: "profile_blank")
            }
            if post.medias.count > 0 {
                let urlString = post.medias[0].url
                if previousPostImageURL != urlString {
                    previousPostImageURL = urlString
                    
                    itemImageView.alpha = 0
                    newTagImageView.alpha = 0
                    
                    let url = NSURL(string: urlString!)!
                    itemImageView.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
                        self.itemImageView.image =  image
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.itemImageView.alpha = 1
                            self.newTagImageView.alpha = 1
                        })
                        }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                            print(error)
                    })
                }
            }
            itemNameLabel.text = post.title
            postAtLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
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
        // Initialization code
        itemImageView.layer.cornerRadius = 5
        itemImageView.clipsToBounds = true
        soldView.layer.cornerRadius = 5
        soldView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
    }
}