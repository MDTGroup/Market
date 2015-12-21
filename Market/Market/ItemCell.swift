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
    
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var newTagImageView: UIImageView!
    
    weak var delegate: ItemCellDelegate?
    
    var avatarTapGesture: UITapGestureRecognizer!
    var sellerTapGesture: UITapGestureRecognizer!
    
    var loadingView: UIActivityIndicatorView!
    
    var item: Post! {
        didSet {
            let post = item
            // Set seller
            sellerLabel.text = post.user.fullName
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
                itemImageView.image = nil
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
            descriptionLabel.text = post.descriptionText
            
            timeAgoLabel.text = Helper.timeSinceDateToNow(post.createdAt!)
            
            priceLabel.text = post.price.formatCurrency()
            newTagImageView.hidden = (post.condition > 0)
            
            if post.iSaveIt == nil {
                post.savedPostCurrentUser({ (saved, error) -> Void in
                    post.iSaveIt = saved
                    self.setSaveLabel(post.iSaveIt!)
                })
            } else {
                setSaveLabel(post.iSaveIt!)
            }
            if post.iVoteIt == nil {
                post.votedPostCurrentUser({ (voted, error) -> Void in
                    post.iVoteIt = voted
                    self.setVoteCountLabel(post.voteCounter, voted: post.iVoteIt!)
                })
            } else {
                setVoteCountLabel(post.voteCounter, voted: post.iVoteIt!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true
        //    itemImageView.layer.cornerRadius = 8
        //    itemImageView.clipsToBounds = true
        //    priceLabel.layer.cornerRadius = 5
        //    priceLabel.clipsToBounds = true
        imageContainer.layer.cornerRadius = 8
        imageContainer.clipsToBounds = true
        
        avatarTapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
        sellerTapGesture = UITapGestureRecognizer(target: self, action: "tapOnProfile:")
        avatarImageView.addGestureRecognizer(avatarTapGesture)
        sellerLabel.addGestureRecognizer(sellerTapGesture)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setSaveLabel(saved: Bool) {
        if saved {
            saveButton.setImage(UIImage(named: "save"), forState: .Normal)
        } else {
            saveButton.setImage(UIImage(named: "save_gray"), forState: .Normal)
        }
    }
    
    func setVoteCountLabel(count: Int, voted: Bool) {
        if voted {
            voteButton.setImage(UIImage(named: "thumb"), forState: .Normal)
            voteCountLabel.textColor = MyColors.bluesky
        } else {
            voteButton.setImage(UIImage(named: "thumb_gray"), forState: .Normal)
            voteCountLabel.textColor = UIColor.lightGrayColor()
        }
        voteCountLabel.text = "\(count)"
        voteCountLabel.hidden = !(count > 0)
    }
    
    @IBAction func onVoteChanged(sender: UIButton) {
        if sender.imageView?.image == UIImage(named: "thumb") {
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
        if sender.imageView?.image == UIImage(named: "save") {
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
    
    func tapOnProfile(gesture: UITapGestureRecognizer) {
        print("i tap on profile pic/name")
        self.delegate?.itemCell?(self, tapOnProfile: true)
    }
}
