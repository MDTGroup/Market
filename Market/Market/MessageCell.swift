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
            
            if let currentUser = User.currentUser(), userObjectId = currentUser.objectId {
                if let user = conversation.toUser {
                    if let avatar = user.avatar, url = avatar.url {
                        self.userImage.setImageWithURL(NSURL(string: url)!)
                    } else {
                        self.userImage.image = UIImage(named: "profile_blank")
                    }
                    self.userFullname.text = user.fullName
                    
                    if let message = conversation.lastMessage {
                        var text = message.text
                        if message.user.objectId == currentUser.objectId {
                            text = "You: \(text)"
                        }
                        self.lastMessageLabel.text = text
                        self.timeElapedLabel.text = Helper.timeSinceDateToNow(message.createdAt!)
                    }
                }
                
                if conversation.readUsers.contains(userObjectId) {
                    userFullname.font = UIFont.systemFontOfSize(14)
                    timeElapedLabel.font = UIFont.systemFontOfSize(12)
                    lastMessageLabel.font = UIFont.systemFontOfSize(12)
                    backgroundColor = UIColor.whiteColor()
                } else {
                    userFullname.font = UIFont.boldSystemFontOfSize(14)
                    timeElapedLabel.font = UIFont.boldSystemFontOfSize(12)
                    lastMessageLabel.font = UIFont.boldSystemFontOfSize(12)
                    backgroundColor = MyColors.highlightForNotification
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = 21
        userImage.layer.masksToBounds = true
    }
    
}