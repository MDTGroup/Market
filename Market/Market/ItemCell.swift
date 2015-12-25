//
//  ItemCell.swift
//  Market
//
//  Created by Dave Vo on 12/8/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import AFNetworking
import Haneke

@objc protocol ItemCellDelegate {
    optional func itemCell(itemCell: ItemCell, didChangeVote value: Bool, voteCount: Int)
    optional func itemCell(itemCell: ItemCell, didChangeSave value: Bool)
    optional func itemCell(itemCell: ItemCell, tapOnProfile value: Bool)
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gap2Columns: NSLayoutConstraint!
    @IBOutlet weak var avatarToItemImage: NSLayoutConstraint!
    @IBOutlet weak var voteButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var chatButtonWidth: NSLayoutConstraint!
    
    weak var delegate: ItemCellDelegate?
    
    var avatarTapGesture: UITapGestureRecognizer!
    var sellerTapGesture: UITapGestureRecognizer!
    
    var loadingView: UIActivityIndicatorView!
    
    var item: Post! {
        didSet {
            let post = item
            // Set seller
            //sellerLabel.text = post.user.fullName
            if let avatar = post.user.avatar {
                //        avatarImageView.alpha = 0.0
                //        avatarImageView.image = nil
                //        UIView.animateWithDuration(0.3, animations: {
                //          self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                //          self.avatarImageView.alpha = 1.0
                //        })
                
                // Set it nil first to prevent it reuses image from other cell when new post
                avatarImageView.image = nil
                avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
            } else {
                avatarImageView.image = UIImage(named: "profile_blank")
            }
            
            // Set Item
            if post.medias.count > 0 {
                //loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                //loadingView.center = CGPoint(x: 40, y: 40)
                //print(loadingView.frame)
                //loadingView.hidesWhenStopped = true
                //loadingView.startAnimating()
                //itemImageView.addSubview(loadingView)
                itemImageView.alpha = 0.0
                //itemImageView.image = UIImage(named: "camera")
                UIView.animateWithDuration(0.3, animations: {
                    self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
                    self.itemImageView.alpha = 1.0
                    }, completion: { (finished) -> Void in
                        //self.loadingView.stopAnimating()
                        //self.loadingView.removeFromSuperview()
                })
                
                // Set it nil first to prevent it reuses image from other cell when new post
                //itemImageView.image = UIImage(named: "camera")
                //itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
            } else {
                // Load no image
            }
            
            itemNameLabel.text = post.title
            //descriptionLabel.text = post.descriptionText
            
            // The size of the descText to fit its content
            //            let newSize = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.frame.width, height: CGFloat.max))
            //            print(newSize.height)
            //            avatarToItemImage.constant = newSize.height > 40 ? 5 : -13
            
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.createdAt!)
            //            let formatter = NSDateFormatter()
            //            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            //            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            //            timeAgoLabel.text = "Posted on \(formatter.stringFromDate(post.updatedAt!))"
            
            priceLabel.text = post.price.formatVND()
            newTagImageView.hidden = (post.condition > 0)
            
            if post.iSaveIt == nil {
                post.savedPostCurrentUser({ (saved, error) -> Void in
                    post.iSaveIt = saved
                    //self.setSaveLabel(post.iSaveIt!)
                })
            } else {
                //setSaveLabel(post.iSaveIt!)
            }
            if post.iVoteIt == nil {
                post.votedPostCurrentUser({ (voted, error) -> Void in
                    post.iVoteIt = voted
                    //self.setVoteCountLabel(post.voteCounter, voted: post.iVoteIt!)
                })
            } else {
                //setVoteCountLabel(post.voteCounter, voted: post.iVoteIt!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = MyColors.themeColor.CGColor
        avatarImageView.clipsToBounds = true
        //itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        //priceLabel.layer.cornerRadius = 5
        //priceLabel.clipsToBounds = true
        
        avatarTapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
        //sellerTapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
        avatarImageView.addGestureRecognizer(avatarTapGesture)
        //sellerLabel.addGestureRecognizer(sellerTapGesture)
        
        // Set the gradientView
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        let color1 = UIColor.clearColor().CGColor as CGColorRef
        let color2 = MyColors.bgColor.CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 0.5]
        
        gradientView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setSaveLabel(saved: Bool) {
        if saved {
            saveButton.setImage(UIImage(named: "save_on"), forState: .Normal)
        } else {
            saveButton.setImage(UIImage(named: "save_gray"), forState: .Normal)
        }
    }
    
    func setVoteCountLabel(count: Int, voted: Bool) {
        if voted {
            voteButton.setImage(UIImage(named: "thumb_on"), forState: .Normal)
            voteCountLabel.textColor = MyColors.bluesky
        } else {
            voteButton.setImage(UIImage(named: "thumb_gray"), forState: .Normal)
            voteCountLabel.textColor = UIColor.lightGrayColor()
        }
        voteCountLabel.text = "\(count)"
        voteCountLabel.hidden = !(count > 0)
    }
    
    @IBAction func onVoteChanged(sender: UIButton) {
        if sender.imageView?.image == UIImage(named: "thumb_on") {
            // Un-vote it
            let count = Int(self.voteCountLabel.text!)! - 1
            setVoteCountLabel(count, voted: false)
            
            item.vote(false) { (successful: Bool, error: NSError?) -> Void in
                if successful {
                    print("unvoted")
                    self.item.iVoteIt = false
                    self.delegate?.itemCell?(self, didChangeVote: true, voteCount: count)
                } else {
                    print("failed to unvote")
                    self.setVoteCountLabel(count + 1, voted: true)
                }
            }
            
        } else {
            // Vote it
            let count = Int(self.voteCountLabel.text!)! + 1
            setVoteCountLabel(count, voted: true)
            item.vote(true) { (successful: Bool, error: NSError?) -> Void in
                if successful {
                    print("voted")
                    self.item.iVoteIt = true
                    self.delegate?.itemCell?(self, didChangeVote: true, voteCount: count)
                } else {
                    print("failed to vote")
                    self.setVoteCountLabel(count - 1, voted: false)
                }
            }
        }
    }
    
    @IBAction func onSaveChanged(sender: UIButton) {
        if sender.imageView?.image == UIImage(named: "save_on") {
            // Un-save it
            setSaveLabel(false)
            item.save(false) { (successful: Bool, error: NSError?) -> Void in
                if successful {
                    print("unsaved")
                    self.item.iSaveIt = false
                    self.delegate?.itemCell?(self, didChangeSave: false)
                } else {
                    print("failed to unsave")
                    self.setSaveLabel(true)
                }
            }
            
        } else {
            // Save it
            setSaveLabel(true)
            item.save(true) { (successful: Bool, error: NSError?) -> Void in
                if successful {
                    print("saved")
                    self.item.iSaveIt = true
                    self.delegate?.itemCell?(self, didChangeSave: true)
                } else {
                    print("failed to save")
                    self.setSaveLabel(false)
                }
            }
        }
    }
    
    @IBAction func onMessage(sender: UIButton) {
        ParentChatViewController.show(item, fromUser: User.currentUser()!, toUser: item.user)
    }
    
    func tapOnProfile(gesture: UITapGestureRecognizer) {
        self.delegate?.itemCell?(self, tapOnProfile: true)
    }
}
