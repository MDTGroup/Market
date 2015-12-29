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
import Parse
import AVKit
import AVFoundation

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate {
    
    var timer = NSTimer()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var users = [User]()
    
    var outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(MyColors.green)
    var incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profile_blank"), diameter: 30)
    var isLoading = false
    var isLoadingEarlierMessages = false
    var conversation: Conversation!
    let maxResultPerRequest = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = User.currentUser() {
            senderId = currentUser.objectId!
            senderDisplayName = currentUser.fullName
        }
        
        if let sendButton = inputToolbar?.contentView?.rightBarButtonItem {
            sendButton.setTitleColor(MyColors.green, forState: UIControlState.Normal)
            sendButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        }
        
        
        isLoading = false
        isLoadingEarlierMessages = false
        
        loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.showLoadEarlierMessagesHeader = false
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.15, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
        conversation.markRead { (success, error) -> Void in
            TabBarController.instance.onRefreshMessageBadge(nil)
        }
        
        inputToolbar?.contentView?.textView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TabBarController.newMessage, object: nil)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        sendMessage(text, video: nil, photo: nil, location: nil)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        view.endEditing(true)
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if let currentUser = User.currentUser() {
            if let address = currentUser.address where !address.isEmpty {
                let shareAddressAction = UIAlertAction(title: "Share address", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    self.sendMessage(address, video: nil, photo: nil, location: nil)
                }
                alertVC.addAction(shareAddressAction)
            }
            
            if let phoneNumber = currentUser.phone where !phoneNumber.isEmpty {
                let shareAddressAction = UIAlertAction(title: "Share phone number", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    self.sendMessage(phoneNumber, video: nil, photo: nil, location: nil)
                }
                alertVC.addAction(shareAddressAction)
            }
        }

        let shareCurrentLocation = UIAlertAction(title: "Share current location", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            PFGeoPoint.geoPointForCurrentLocationInBackground({ (currentGeoPoint, error) -> Void in
                guard error == nil else {
                    if let message = error?.userInfo["error"] as? String {
                        AlertControl.show(self, title: "Share current location", message: message, handler: nil)
                    }
                    print(error)
                    return
                }
                if  let currentGeoPoint = currentGeoPoint {
                    self.sendMessage("", video: nil, photo: nil, location: currentGeoPoint)
                }
            })
        }
        alertVC.addAction(shareCurrentLocation)
        
        let takePhotoAction = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            Camera.shouldStartCamera(self, canEdit: true, frontFacing: false)
        }
        alertVC.addAction(takePhotoAction)
        
        let choosePhotoAction = UIAlertAction(title: "Choose photo", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            Camera.shouldStartPhotoLibrary(self, canEdit: true)
        }
        alertVC.addAction(choosePhotoAction)
        
        let chooseVideoAction = UIAlertAction(title: "Choose video", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            Camera.shouldStartVideoLibrary(self, canEdit: true)
        }
        alertVC.addAction(chooseVideoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
        }
        alertVC.addAction(cancelAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
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
        
        cell.avatarImageView?.contentMode = .ScaleAspectFill
        
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
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.presentViewController(playerController, animated: true) {
                    player.play()
                }
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
    }
    
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let collectionReusableView = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        if let collectionReusableView = collectionReusableView as? JSQMessagesLoadEarlierHeaderView,
            button = collectionReusableView.loadButton {
            button.tintColor = MyColors.green
            button.titleLabel?.textColor = MyColors.green
        }
        return collectionReusableView
    }
}

// MARK: Backend
extension ChatViewController {
    func loadEarlierMessages() {
        if !isLoadingEarlierMessages {
            isLoadingEarlierMessages = true
            let firstMessage = messages.first
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
            jsqMessages.append(prepareJSQMessage(message))
            users.append(message.user)
        }
        
        self.users.insertContentsOf(users, at: 0)
        self.messages.insertContentsOf(jsqMessages, at: 0)
    }
    
    func prepareJSQMessage(message: Message) -> JSQMessage {
        let jsqMessage: JSQMessage!
        if let video = message.video {
            let videoItem = JSQVideoMediaItem(fileURL: NSURL(string: video.url!)!, isReadyToPlay: true)
            videoItem.appliesMediaViewMaskAsOutgoing = message.user.objectId! == self.senderId
            jsqMessage = JSQMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt!, media: videoItem)
        } else if let photo = message.photo {
            let photoItem = JSQPhotoMediaItem(image: nil)
            photoItem.appliesMediaViewMaskAsOutgoing = message.user.objectId! == self.senderId
            jsqMessage = JSQMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt!, media: photoItem)
            photo.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                if let imageData = imageData {
                    photoItem.image = UIImage(data: imageData)
                    self.collectionView!.reloadData()
                } else {
                    print("ImageData is nil")
                }
            })
        } else if let location = message.location {
            let locationItem = JSQLocationMediaItem(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
            locationItem.appliesMediaViewMaskAsOutgoing = message.user.objectId! == self.senderId
            jsqMessage = JSQMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt!, media: locationItem)
        } else {
            jsqMessage = JSQMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt!, text: message.text)
        }
        return jsqMessage
    }

    func loadMessages() {
        if !isLoading {
            isLoading = true
            let lastMessage = messages.last
            
            conversation.getMessages(lastMessage?.date, maxResultPerRequest: maxResultPerRequest, callback: { (messages, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                self.automaticallyScrollsToMostRecentMessage = true
                
                if let messages = messages where messages.count > 0 {
                    self.addMessages(messages)
                    self.finishReceivingMessage()
                    self.scrollToBottomAnimated(false)
                    self.showLoadEarlierMessagesHeader = messages.count >= self.maxResultPerRequest
                    if lastMessage != nil {
                        self.conversation.markRead {
                            (success, error) -> Void in
                        }
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
            jsqMessages.append(prepareJSQMessage(message))
            users.append(message.user)
        }
        
        self.users.appendContentsOf(users)
        self.messages.appendContentsOf(jsqMessages)
    }
    
    func sendMessage(text: String, video: NSURL?, photo: UIImage?, location: PFGeoPoint?) {
        var message = text
        var videoFile: PFFile?
        var photoFile: PFFile?
        
        if let video = video {
            message = "sent a video."
            videoFile = PFFile(name: "video.mp4", data: NSFileManager.defaultManager().contentsAtPath(video.path!)!)
//            videoFile?.saveInBackgroundWithBlock({ (success, error) -> Void in
//                if error != nil {
//                    print(error)
//                }
//            })
        }
        
        if let photo = photo {
            message = "sent a photo."
            photoFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(photo, 0.4)!)
//            photoFile?.saveInBackgroundWithBlock({ (success, error) -> Void in
//                if error != nil {
//                    print(error)
//                }
//            })
        }
        
        if location != nil {
            message = "send their location."
        }
        
        conversation.addMessage(User.currentUser()!, text: message, videoFile: videoFile, photoFile: photoFile, location: location) { (success, error) -> Void in
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

extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let video = info[UIImagePickerControllerMediaURL] as? NSURL
        
        var photoAfterCompress: UIImage?
        if let photo = info[UIImagePickerControllerEditedImage] as? UIImage {
            let newWidth = photo.size.width > 400 ? 400 : photo.size.width
            photoAfterCompress = Helper.resizeImage(photo, newWidth: newWidth)
        }
        self.sendMessage("", video: video, photo: photoAfterCompress, location: nil)

        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}