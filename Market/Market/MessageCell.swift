//
//  MessageCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/17/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFullname: UILabel!
    @IBOutlet weak var timeElapedLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    var conversation: Conversation! {
        didSet {
            
            lastMessageLabel.text = ""
            timeElapedLabel.text = ""
            self.userFullname.text = ""
            
            if let currentUser = User.currentUser() {
                for user in conversation.users {
                    if user.objectId != currentUser.objectId {
                        user.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                            if let avatar = user.avatar {
                                self.userImage.alpha = 0.0
                                UIView.animateWithDuration(0.3, animations: {
                                    self.userImage.setImageWithURL(NSURL(string: avatar.url!)!)
                                    self.userImage.alpha = 1.0
                                    }, completion: nil)
                            }
                            self.userFullname.text = user.fullName
                        }
                        break
                    }
                }
                
                let messageQuery = conversation.messages.query()
                messageQuery.orderByDescending("createdAt")
                messageQuery.limit = 1
                messageQuery.findObjectsInBackgroundWithBlock({ (messages, error) -> Void in
                    guard error == nil else {
                        print(error)
                        return
                    }
                    
                    if let messages = messages as? [Message] {
                        if messages.count > 0 {
                            let message = messages[0]
                            var text = message.text
                            if message.user.objectId == currentUser.objectId {
                                text = "You: \(text)"
                            }
                            self.lastMessageLabel.text = text
                            self.timeElapedLabel.text = Helper.timeSinceDateToNow(message.createdAt!)
                        }
                    }
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = 21
        userImage.layer.masksToBounds = true
    }
    
}