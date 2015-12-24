//
//  ChatViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/17/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Foundation
import MediaPlayer
import MBProgressHUD

class ChatViewController: JSQMessagesViewController {
    
    var timer = NSTimer()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var users = [User]()
    
    var outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    var incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profile_blank"), diameter: 30)
    var isLoading = false
    var isLoadingEarlierMessages = false
    var conversation: Conversation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputToolbar?.contentView?.leftBarButtonItem = nil
        
        if let currentUser = User.currentUser() {
            senderId = currentUser.objectId!
            senderDisplayName = currentUser.fullName
        }
        
        isLoading = false
        isLoadingEarlierMessages = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onPushNotificationMessage:", name: TabBarController.newMessage, object: nil)
        conversation.markRead { (success, error) -> Void in
            TabBarController.instance.onRefreshMessageBadge(nil)
        }
        
        showLoadEarlierMessagesHeader = true
    }
    
    func onPushNotificationMessage(notification: Notification) {
        conversation.markRead {
            (success, error) -> Void in
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TabBarController.newMessage, object: nil)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        sendMessage(text)
    }
    
    //    override func didPressAccessoryButton(sender: UIButton!) {
    //        let action = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take photo", "Choose existing photo", "Choose existing video")
    //        action.showInView(view)
    //    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImage
        }
        
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let user = users[indexPath.item]
        if avatars[user.objectId!] == nil {
            user.avatar?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                
                self.avatars[user.objectId!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: imageData!), diameter: 30)
                self.collectionView!.reloadData()
            })
            return blankAvatarImage
        } else {
            return avatars[user.objectId!]
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.senderId == senderId {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        loadEarlierMessages()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        let tapUser = users[indexPath.row]
        if tapUser.objectId != User.currentUser()?.objectId {
            let userTimelineVC = UserTimelineViewController.instantiateViewController
            userTimelineVC.user = tapUser
            presentViewController(userTimelineVC, animated: true, completion: nil)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        //        let message = messages[indexPath.item]
        //        if message.isMediaMessage {
        //            if let mediaItem = message.media as? JSQVideoMediaItem {
        //                let moviePlayer = MPMoviePlayerViewController(contentURL: mediaItem.fileURL)
        //                presentMoviePlayerViewControllerAnimated(moviePlayer)
        //                moviePlayer.moviePlayer.play()
        //            }
        //        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
    }
}

// MARK: Backend
extension ChatViewController {
    func loadEarlierMessages() {
        if !isLoadingEarlierMessages {
            isLoadingEarlierMessages = true
            let firstMessage = messages.first
            print("firstMessage", firstMessage?.date)
            conversation.getEarlierMessages(firstMessage?.date, callback: { (messages, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                self.automaticallyScrollsToMostRecentMessage = false
                if let messages = messages {
                    self.addEarlierMessages(messages)
                    if messages.count > 0 {
                        self.finishReceivingMessage()
                    } else {
                        self.showLoadEarlierMessagesHeader = false
                    }
                }
                self.isLoadingEarlierMessages = false
            })
        }
    }
    
    func addEarlierMessages(messages: [Message]) {
        var jsqMessages = [JSQMessage]()
        var users = [User]()
        for message in messages {
            let jsqMessage = JSQMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt!, text: message.text)
            jsqMessages.append(jsqMessage)
            users.append(message.user)
        }
        
        self.users.insertContentsOf(users, at: 0)
        self.messages.insertContentsOf(jsqMessages, at: 0)
    }

    func loadMessages() {
        if !isLoading {
            isLoading = true
            let lastMessage = messages.last
            
            conversation.getMessages(lastMessage?.date, callback: { (messages, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                self.automaticallyScrollsToMostRecentMessage = true
                
                if let messages = messages {
                    self.addMessages(messages)
                    if messages.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                }
                
                self.isLoading = false
            })
        }
    }
    
    func addMessages(messages: [Message]) {
        var jsqMessages = [JSQMessage]()
        var users = [User]()
        for message in messages {
            let jsqMessage = JSQMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt!, text: message.text)
            jsqMessages.append(jsqMessage)
            users.append(message.user)
        }
        
        self.users.appendContentsOf(users)
        self.messages.appendContentsOf(jsqMessages)
    }
    
    func sendMessage(text: String) {
        conversation.addMessage(User.currentUser()!, text: text) { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.loadMessages()
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
        }
        self.finishSendingMessage()
    }
}

//extension ChatViewController: UIActionSheetDelegate {
//    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
////        if buttonIndex != actionSheet.cancelButtonIndex {
////            if buttonIndex == 1 {
////                Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
////            } else if buttonIndex == 2 {
////                Camera.shouldStartPhotoLibrary(self, canEdit: true)
////            } else if buttonIndex == 3 {
////                Camera.shouldStartVideoLibrary(self, canEdit: true)
////            }
////        }
//    }
//}
//
//extension ChatViewController: UIImagePickerControllerDelegate {
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let video = info[UIImagePickerControllerMediaURL] as? NSURL
//        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
//
////        self.sendMessage("", video: video, picture: picture)
//
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//}