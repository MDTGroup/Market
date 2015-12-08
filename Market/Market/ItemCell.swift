//
//  ItemCell.swift
//  Market
//
//  Created by Dave Vo on 12/8/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol ItemCellDelegate {
  optional func itemCell(tweetCell: ItemCell, didChangeVote value: Bool)
  optional func itemCell(tweetCell: ItemCell, didChangeSave value: Bool)
}

class ItemCell: UITableViewCell {
  
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
  
  weak var delegate: ItemCellDelegate?
  
  var item: Item! {
    didSet {
      // Set seller
      avatarImageView.alpha = 0.0
      UIView.animateWithDuration(0.3, animations: {
        self.avatarImageView.setImageWithURL(NSURL(string: self.item.avatarURL)!)
        self.avatarImageView.alpha = 1.0
        }, completion: nil)
      sellerLabel.text = item.seller
      
      // Set Item
      itemImageView.alpha = 0.0
      UIView.animateWithDuration(0.3, animations: {
        self.itemImageView.setImageWithURL(NSURL(string: self.item.itemImageUrl)!)
        self.itemImageView.alpha = 1.0
        }, completion: nil)
      itemNameLabel.text = item.title
      descriptionLabel.text = item.description
      timeAgoLabel.text = item.timeSincePosted
      priceLabel.text = item.priceString
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    avatarImageView.layer.cornerRadius = 5
    avatarImageView.clipsToBounds = true
    itemImageView.layer.cornerRadius = 18
    itemImageView.clipsToBounds = true
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func onVoteChanged(sender: UIButton) {
    if sender.imageView?.image == UIImage(named: "thumb") {
      // Un-vote it
      sender.setImage(UIImage(named: "thumb_gray"), forState: .Normal)
      self.delegate?.itemCell?(self, didChangeVote: false)
      
    } else {
      // Vote it
      sender.setImage(UIImage(named: "thumb"), forState: .Normal)
      self.delegate?.itemCell?(self, didChangeVote: true)
    }
  }
  
  @IBAction func onSaveChanged(sender: UIButton) {
    if sender.imageView?.image == UIImage(named: "save") {
      // Un-vote it
      sender.setImage(UIImage(named: "save_gray"), forState: .Normal)
      self.delegate?.itemCell?(self, didChangeSave: false)
      
    } else {
      // Vote it
      sender.setImage(UIImage(named: "save"), forState: .Normal)
      self.delegate?.itemCell?(self, didChangeSave: true)
    }
  }
  
}
