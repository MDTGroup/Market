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
    var messages = [JSQCustomMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.automaticallyScrollsToMostRecentMessage = true
        self.inputToolbar?.contentView?.textView?.becomeFirstResponder()
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
        
        // MARK: temporarily disable this because the map is too slow to show
        //        let shareCurrentLocation = UIAlertAction(title: "Share current location", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
        //            PFGeoPoint.geoPointForCurrentLocationInBackground({ (currentGeoPoint, error) -> Void in
        //                guard error == nil else {
        //                    if let message = error?.userInfo["error"] as? String {
        //                        AlertControl.show(self, title: "Share current location", message: message, handler: nil)
        //                    }
        //                    print(error)
        //                    return
        //                }
        //                if  let currentGeoPoint = currentGeoPoint {
        //                    self.sendMessage("", video: nil, photo: nil, location: currentGeoPoint)
        //                }
        //            })
        //        }
        //        alertVC.addAction(shareCurrentLocation)
        
        // Pick photo from library
        let pickPhotoAction = UIAlertAction(title: "Choose photo from library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.PhotoLibrary, mediaType: .PickPhoto)
        })
        alertVC.addAction(pickPhotoAction)
        
        let pickVideoAction = UIAlertAction(title: "Choose video from library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.PhotoLibrary, mediaType: .PickVideo)
        })
        alertVC.addAction(pickVideoAction)
        
        // Take photo/video from camera if camera is avail
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            let takePhotoAction = UIAlertAction(title: "Take photo", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.Camera, mediaType: .TakePhoto)
            })
            alertVC.addAction(takePhotoAction)
            
            let pickVideoAction = UIAlertAction(title: "Record a 30s video", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.Camera, mediaType: .Record30sVideo)
            })
            alertVC.addAction(pickVideoAction)
        }
        
        
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
        let user = messages[indexPath.item].message.user
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
            cell.textView?.linkTextAttributes = ["NSColor" : UIColor.blackColor(), "NSUnderline" : 1]
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
        let tapUser = messages[indexPath.row].message.user
        if tapUser.objectId != User.currentUser()?.objectId {
            let userTimelineVC = UserTimelineViewController.instantiateViewController
            userTimelineVC.user = tapUser
            presentViewController(userTimelineVC, animated: true, completion: nil)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQCustomVideoMediaItem {
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.presentViewController(playerController, animated: true) {
                    player.play()
                }
            } else if let mediaItem = message.media as? JSQPhotoMediaItem {
                let fullImageVC = FullImageViewController.instantiateViewController
                fullImageVC.image = mediaItem.image
                self.presentViewController(fullImageVC, animated: true, completion: nil)
            }
        }
        view.endEditing(true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
        view.endEditing(true)
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
            conversation.getEarlierMessages(firstMessage?.createdAt, callback: { (messages, error) -> Void in
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
        var jsqMessages = [JSQCustomMessage]()
        for message in messages {
            jsqMessages.append(prepareJSQMessage(message))
        }
        
        self.messages.insertContentsOf(jsqMessages, at: 0)
    }
    
    func prepareJSQMessage(message: Message) -> JSQCustomMessage {
        let jsqMessage: JSQCustomMessage!
        if let video = message.video {
            var url: NSURL?
            if let localVideoPath = message.localVideoPath {
                url = NSURL(fileURLWithPath: localVideoPath)
            } else {
                url = NSURL(string: video.url!)
            }
            let videoItem = JSQCustomVideoMediaItem(fileURL: url!, isReadyToPlay: true)
            videoItem.thumbnailURL = message.photo?.url
            videoItem.appliesMediaViewMaskAsOutgoing = message.user.objectId! == self.senderId
            jsqMessage = JSQCustomMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt ?? NSDate(), media: videoItem)
        } else if let photo = message.photo {
            let photoItem = JSQPhotoMediaItem(image: nil)
            photoItem.appliesMediaViewMaskAsOutgoing = message.user.objectId! == self.senderId
            jsqMessage = JSQCustomMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt ?? NSDate(), media: photoItem)
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
            jsqMessage = JSQCustomMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt ?? NSDate(), media: locationItem)
        } else {
            jsqMessage = JSQCustomMessage(senderId: message.user.objectId!, senderDisplayName: message.user.fullName, date: message.createdAt ?? NSDate(), text: message.text)
        }
        jsqMessage.createdAt = message.createdAt ?? NSDate()
        jsqMessage.message = message
        return jsqMessage
    }
    
    func loadMessages() {
        if !isLoading {
            isLoading = true
            var lastMessage: JSQCustomMessage?
            for message in self.messages.reverse() {
                if message.message.objectId != nil {
                    lastMessage = message
                    break
                }
            }
            
            conversation.getMessages(lastMessage?.createdAt, maxResultPerRequest: maxResultPerRequest, callback: { (messages, error) -> Void in
                self.isLoading = false
                guard error == nil else {
                    print(error)
                    return
                }
                
                self.automaticallyScrollsToMostRecentMessage = true
                
                if let messages = messages where messages.count > 0 {
                    self.addMessages(messages)
                    self.finishReceivingMessage()
                    self.scrollToBottomAnimated(false)
                    if lastMessage == nil {
                        self.showLoadEarlierMessagesHeader = messages.count >= self.maxResultPerRequest
                    } else {
                        self.conversation.markRead {
                            (success, error) -> Void in
                        }
                    }
                }
            })
        }
    }
    
    func addMessages(messages: [Message]) {
        var jsqMessages = [JSQCustomMessage]()
        for message in messages {
            
            if message.uniqueBasedUserId.characters.count > 0 {
                if let index = self.messages.indexOf({ (jsqCustomMessage) -> Bool in
                    return jsqCustomMessage.message.uniqueBasedUserId == message.uniqueBasedUserId
                }) {
                    let jsqCustomMessage = prepareJSQMessage(message)
                    self.messages[index].createdAt = jsqCustomMessage.createdAt
                    continue;
                }
            }
            
            jsqMessages.append(prepareJSQMessage(message))
        }
        
        self.messages.appendContentsOf(jsqMessages)
        
        self.messages = self.messages.sort({ (messageA, messageB) -> Bool in
            return messageA.createdAt.compare(messageB.createdAt) == NSComparisonResult.OrderedAscending
        })
    }
    
    func sendMessage(text: String, video: NSURL?, photo: UIImage?, location: PFGeoPoint?) {
        var message = text
        var videoFile: PFFile?
        var photoFile: PFFile?
        
        if let video = video {
            message = "sent a video."
            videoFile = PFFile(name: "video.mp4", data: NSFileManager.defaultManager().contentsAtPath(video.path!)!)
        }
        
        if let photo = photo {
            if message.isEmpty {
                message = "sent a photo."
            }
            photoFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(photo, 0.4)!)
        }
        
        if location != nil {
            message = "send their location."
        }
        
        let newMessage = conversation.addMessage(User.currentUser()!, text: message, videoFile: videoFile, photoFile: photoFile, location: location) { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.loadMessages()
        }
        
        if let newMessage = newMessage {
            newMessage.localVideoPath = video?.path
            self.addMessages([newMessage])
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
        }
        
        self.finishSendingMessage()
    }
}

extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let newWidth = photo.size.width > 400 ? 400 : photo.size.width
            let photoAfterResize = Helper.resizeImage(photo, newWidth: newWidth)
            let photoAfterCompressData = UIImageJPEGRepresentation(photoAfterResize, 0.4)!
            self.sendMessage("", video: nil, photo: UIImage(data: photoAfterCompressData), location: nil)
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.applyCustomTheme("Compressing video...")
            picker.dismissViewControllerAnimated(true, completion: nil)
            let compressedVideoOutputUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("\(NSDate()).mov")
            Helper.compressVideo(videoURL, outputURL: compressedVideoOutputUrl, handler: { (session) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true)
                    if session.status == AVAssetExportSessionStatus.Completed {
                        let data = NSData(contentsOfURL: compressedVideoOutputUrl)
                        if let data = data where data.toMB() >= 10 {
                            self.dismissViewControllerAnimated(true, completion: nil)
                            AlertControl.show(self, title: "File size", message: "You cannot upload video with file size >= 10 mb. Please choose a shorter video.", handler: nil)
                            return
                        }
                        print("File size: \(Double(data!.length / 1024)) kb")
                        self.sendMessage("", video: compressedVideoOutputUrl, photo: compressedVideoOutputUrl.getThumbnailOfVideoURL(), location: nil)
                    } else if session.status == AVAssetExportSessionStatus.Failed {
                        AlertControl.show(self, title: "Compress video", message: "There was a problem compressing the video maybe you can try again later. Error: \(session.error?.localizedDescription)", handler: nil)
                    }
                })
            })
        }
    }
}