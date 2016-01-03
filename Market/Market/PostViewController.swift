//
//  PostViewController.swift
//  Market
//
//  Created by Dave Vo on 12/12/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices
import AVFoundation
import MBProgressHUD

@objc protocol PostViewControllerDelegate {
    optional func postViewController(postViewController: PostViewController, didUploadNewPost post: Post)
}

class PostViewController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var removeButton1: UIButton!
    @IBOutlet weak var removeButton2: UIButton!
    @IBOutlet weak var removeButton3: UIButton!
    
    @IBOutlet weak var videoImage1: UIImageView!
    @IBOutlet weak var videoImage2: UIImageView!
    @IBOutlet weak var videoImage3: UIImageView!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var descTextHeight: NSLayoutConstraint!
    
    @IBOutlet weak var priceLabel: UITextField!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var descPlaceHolder: UILabel!
    
    @IBOutlet weak var conditionSegment: UISegmentedControl!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var draftButton: UIButton!
    @IBOutlet weak var okImageView: UIImageView!
    
    @IBOutlet weak var progressBarLength: NSLayoutConstraint!
    @IBOutlet weak var progressBarLeft: NSLayoutConstraint!
    
    @IBOutlet var iv1SingleTap: UITapGestureRecognizer!
    @IBOutlet var iv2SingleTap: UITapGestureRecognizer!
    @IBOutlet var iv3SingleTap: UITapGestureRecognizer!
    
    var imageViews = [UIImageView]()
    var videoIconImages = [UIImageView]()
    var removeButtons = [UIButton]()
    var medias: [PFFile?] = [nil, nil, nil, nil, nil, nil]
    
    var selectedImageIndex: Int = 0
    var imagesAvail = [Bool](count: 3, repeatedValue: false)
    var editingPost: Post?
    
    let priceMaxLength = 13
    let titleMaxLength = 140
    
    weak var delegate: PostViewControllerDelegate?
    
    var isSubmittingNewPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Determine screen size
        let screenWidth = UIScreen.mainScreen().bounds.width
        imageWidth.constant = screenWidth > 350 ? 100: 90
        imageHeight.constant = imageWidth.constant
        
        imageViews = [imageView1, imageView2, imageView3]
        videoIconImages = [videoImage1, videoImage2, videoImage3]
        removeButtons = [removeButton1, removeButton2, removeButton3]
        
        initControls()
        priceLabel.becomeFirstResponder()
        
        if editingPost != nil {
            title = "Update the item"
            loadPostToUpdate()
            navBar.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: .Plain, target: self, action: "updatePost")
        } else {
            title = "Post new item"
            navBar.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: .Plain, target: self, action: "newPost")
        }
    }
    
    func initControls() {
        resetPostPage()
        
        priceLabel.delegate = self
        titleLabel.delegate = self
        
        descriptionText.layer.cornerRadius = 5
        descriptionText.layer.borderWidth = 1
        descriptionText.layer.borderColor = MyColors.gray.CGColor
        descriptionText.backgroundColor = UIColor.whiteColor()
        descriptionText.clipsToBounds = true
        descriptionText.delegate = self
        
        progressBar.setProgress(0, animated: false)
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds = true
        progressBar.alpha = 0
        okImageView.alpha = 0
    }
    
    func hideInstruction() {
        //        UIView.animateWithDuration(0.1, animations: { () -> Void in
        //            self.instructionView.center.x -= 5
        //            }) { (finished) -> Void in
        //                self.imageView2.alpha = 0
        //                self.imageView3.alpha = 0
        //                self.conditionSegment.alpha = 0
        //                self.imageView2.hidden = false
        //                self.imageView3.hidden = false
        //                self.conditionSegment.hidden = false
        //
        //                UIView.animateWithDuration(0.5, animations: { () -> Void in
        //                    self.instructionView.center.x += UIScreen.mainScreen().bounds.width
        //                    self.imageView2.alpha = 1
        //                    self.imageView3.alpha = 1
        //                    self.conditionSegment.alpha = 1
        //                    }, completion: { (finished) -> Void in
        //                        self.instructionView.hidden = true
        //                })
        //        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func loadPostToUpdate() {
        if let editingPost = editingPost {
            priceLabel.text = "\(Int(editingPost.price))"
            titleLabel.text = editingPost.title
            descriptionText.text = editingPost.descriptionText
            descPlaceHolder.hidden = true
            conditionSegment.selectedSegmentIndex = editingPost.condition
            
            let numImages = editingPost.medias.count / 2
            for i in 0..<numImages {
                let thumbnailMedia = editingPost.medias[i * 2]
                if let thumbnailURL = thumbnailMedia.url {
                    let imageView = imageViews[i]
                    imageView.image = UIImage(named: "loading")
                    imageView.setImageWithURL(NSURL(string: thumbnailURL)!)
                    imageView.contentMode = .ScaleAspectFill
                    medias[i * 2] = thumbnailMedia
                    let originalMedia = editingPost.medias[(i * 2) + 1]
                    medias[(i * 2) + 1] = originalMedia
                    if let originalURL = originalMedia.url {
                        videoIconImages[i].hidden = originalURL.rangeOfString("video.mov") == nil
                    }
                    imagesAvail[i] = true
                    removeButtons[i].hidden = false
                }
            }
        }
    }
    
    func initImageFrame(iv: UIImageView) {
        iv.layer.borderColor = MyColors.green.CGColor
        iv.layer.borderWidth = 0.5
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.image = UIImage(named: "camera")
        iv.contentMode = .Center
        
        switch iv {
        case imageView1:
            removeButton1.hidden = true
            videoImage1.hidden = true
        case imageView2:
            removeButton2.hidden = true
            videoImage2.hidden = true
        case imageView3:
            removeButton3.hidden = true
            videoImage3.hidden = true
        default: break
        }
    }
    
    func setImageToSelectedImageView(image: UIImage, videoFile: PFFile?) {
        
        let thumbnailImage = Helper.resizeImage(image, newWidth: 750)
        let thumbnailImageCompressed = UIImageJPEGRepresentation(thumbnailImage, 0.2)!
        let thumbnailFile = PFFile(name: "thumb\(selectedImageIndex + 1).jpg", data: thumbnailImageCompressed)
        medias[selectedImageIndex * 2] = thumbnailFile
        
        if let videoFile = videoFile {
            medias[(selectedImageIndex * 2) + 1] = videoFile
        } else {
            let resizedImage = Helper.resizeImage(image, newWidth: 1600)
            let imageCompressed = UIImageJPEGRepresentation(resizedImage, 0.4)!
            medias[(selectedImageIndex * 2) + 1] = PFFile(name: "img\(selectedImageIndex + 1).jpg", data: imageCompressed)
        }
        
        
        let imageView = imageViews[selectedImageIndex]
        imageView.image = UIImage(data: thumbnailImageCompressed)
        imageView.contentMode = .ScaleAspectFill
        removeButtons[selectedImageIndex].hidden = false
        videoIconImages[selectedImageIndex].hidden = videoFile == nil
        imagesAvail[selectedImageIndex] = true
    }
    
    func preparePost() -> Post? {
        let post = Post()
        var images = [UIImage]()
        
        if imagesAvail[0] {
            images.append(imageView1.image!)
        }
        if imagesAvail[1] {
            images.append(imageView2.image!)
        }
        if imagesAvail[2] {
            images.append(imageView3.image!)
        }
        
        // Input validation
        if images.count == 0 {
            AlertControl.show(self, title: "Market", message: "Please add at least 1 image/video", handler: nil)
            return nil
        }
        
        if priceLabel.text!.isEmpty {
            AlertControl.show(self, title: "Market", message: "Please enter the price", handler: { (alertAction) -> Void in
                self.priceLabel.becomeFirstResponder()
            })
            return nil
        } else if let price = Double(priceLabel.text!) where price <= 0 {
            AlertControl.show(self, title: "Market", message: "Please input valid price. Must be greater than 0", handler: { (alertAction) -> Void in
                self.priceLabel.becomeFirstResponder()
            })
            return nil
        }
        
        if titleLabel.text!.isEmpty {
            AlertControl.show(self, title: "Market", message: "Please enter the title", handler: { (alertAction) -> Void in
                self.titleLabel.becomeFirstResponder()
            })
            return nil
        }
        
        if descriptionText.text!.isEmpty {
            AlertControl.show(self, title: "Market", message: "Please enter the description", handler: { (alertAction) -> Void in
                self.descriptionText.becomeFirstResponder()
            })
            return nil
        }
        
        post.title = titleLabel.text!
        post.price = Double(priceLabel.text!)!
        post.condition = conditionSegment.selectedSegmentIndex // 0 = new, 1 = used
        post.descriptionText = descriptionText.text
        
        
        
        // Attach image/video
        for i in 0..<medias.count {
            if let media = medias[i] {
                post.medias.append(media)
            }
        }
        
        return post
    }
    
    func resetPostPage() {
        for imageView in imageViews {
            initImageFrame(imageView)
        }
        priceLabel.text = ""
        descriptionText.text = ""
        titleLabel.text = ""
        progressBar.setProgress(0, animated: false)
        progressBar.alpha = 0
        okImageView.alpha = 0
        medias = [nil, nil, nil, nil, nil, nil]
    }
    
    func newPost() {
        if isSubmittingNewPost {
            AlertControl.show(self, title: "Submit post", message: "Your post is uploading, please wait!", handler: nil)
            return
        }
        if let post = preparePost() {
            showProgressBar()
            // Set these initial values only for new post
            post.sold = false
            post.isDeleted = false
            post.voteCounter = 0
            post.vote = Vote()
            isSubmittingNewPost = true
            post.saveWithCallbackProgressAndFinish({ (post: Post) -> Void in
                print(post)
                self.isSubmittingNewPost = false
                self.okImageView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    // MARK: Send Notifications
                    self.sendNotificationForNewPost(post)
                    
                    self.okImageView.transform = CGAffineTransformMakeScale(1, 1)
                    self.okImageView.alpha = 1
                    }, completion: { (finished) -> Void in
                        self.resetPostPage()
                        self.delegate?.postViewController?(self, didUploadNewPost: post)
                        self.tabBarController!.selectedIndex = 0
                })
                
                }) { (post: Post, percent: Float) -> Void in
                    print(percent)
                    self.progressBar.setProgress(percent, animated: true)
            }
        }
    }
    
    func updatePost() {
        if isSubmittingNewPost {
            AlertControl.show(self, title: "Submit post", message: "Your post is uploading, please wait!", handler: nil)
            return
        }
        print("updating post")
        if let newPost = preparePost() {
            showProgressBar()
            let post = Post(withoutDataWithObjectId: (editingPost?.objectId)!)
            isSubmittingNewPost = true
            post.fetchInBackgroundWithBlock { (fetchedPFObj, error) -> Void in
                print(fetchedPFObj)
                
                if let fetchedPost = fetchedPFObj as? Post {
                    
                    var changeDescription = ""
                    if fetchedPost.title != newPost.title {
                        fetchedPost.title = newPost.title
                        changeDescription += "title"
                    }
                    
                    if fetchedPost.descriptionText != newPost.descriptionText {
                        fetchedPost.descriptionText = newPost.descriptionText
                        changeDescription += "description"
                    }
                    
                    if fetchedPost.price != newPost.price {
                        fetchedPost.price = newPost.price
                        changeDescription += "price"
                    }
                    
                    if fetchedPost.condition != newPost.condition {
                        fetchedPost.condition = newPost.condition
                        changeDescription += "condition"
                    }
                    
                    if fetchedPost.sold != newPost.sold {
                        fetchedPost.sold = newPost.sold
                        changeDescription += "sold"
                    }
                    
                    if fetchedPost.location != newPost.location {
                        fetchedPost.location = newPost.location
                        changeDescription += "location"
                    }
                    
                    fetchedPost.medias = newPost.medias
                    //                    if self.isMediaChanged {
                    //                        fetchedPost.medias = newPost.medias
                    //                        changeDescription += "media"
                    //                    }
                    
                    fetchedPost.saveWithCallbackProgressAndFinish({ (post: Post) -> Void in
                        self.isSubmittingNewPost = false
                        // MARK: Send Notifications
                        self.sendNotificationForUpdatedPost(post, changeDescription: changeDescription)
                        
                        self.okImageView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.okImageView.transform = CGAffineTransformMakeScale(1, 1)
                            self.okImageView.alpha = 1
                            }, completion: { (finished) -> Void in
                                self.resetPostPage()
                                self.delegate?.postViewController?(self, didUploadNewPost: post)
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                        
                        }) { (post: Post, percent: Float) -> Void in
                            print(percent)
                            self.progressBar.setProgress(percent, animated: true)
                    }
                } else {
                    print("Not able to update post :(")
                    self.isSubmittingNewPost = false
                }
            }
            
        }
    }
    
    func showProgressBar() {
        view.endEditing(true)
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
            self.progressBar.alpha = 1
        }
    }
    
    @IBAction func onRemoveImage1(sender: UIButton) {
        medias[0] = nil
        medias[1] = nil
        initImageFrame(imageView1)
        imagesAvail[0] = false
    }
    
    @IBAction func onRemoveImage2(sender: UIButton) {
        medias[2] = nil
        medias[3] = nil
        initImageFrame(imageView2)
        imagesAvail[1] = false
    }
    
    @IBAction func onRemoveImage3(sender: UIButton) {
        medias[4] = nil
        medias[5] = nil
        initImageFrame(imageView3)
        imagesAvail[2] = false
    }
    
    @IBAction func onDismiss(sender: UIBarButtonItem) {
        if editingPost != nil {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.tabBarController!.selectedIndex = 0
        }
    }
}

// MARK: - Image Picker
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? NSString where mediaType == kUTTypeMovie {
            let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
            
            if let videoURL = videoURL {
                picker.dismissViewControllerAnimated(true, completion: nil)
                let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
                hud.applyCustomTheme("Compressing video...")
                let compressedVideoOutputUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("\(NSDate()).mov")
                Helper.compressVideo(videoURL, outputURL: compressedVideoOutputUrl, handler: { (session) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        hud.hide(true)
                        if session.status == AVAssetExportSessionStatus.Completed {
                            let data = NSData(contentsOfURL: compressedVideoOutputUrl)
                            if let data = data where data.toMB() >= 10 {
                                AlertControl.show(self, title: "File size", message: "You cannot upload video with file size >= 10 mb. Please choose a shorter video.", handler: nil)
                                return
                            }
                            let videoPFFile = PFFile(name: "video.mov", data: NSData(data: data!))
                            print("File size: \(Double(data!.length / 1024)) kb")
                            // Get the thumbnail of video
                            if let image = videoURL.getThumbnailOfVideoURL() {
                                self.setImageToSelectedImageView(image, videoFile: videoPFFile)
                            }
                        } else if session.status == AVAssetExportSessionStatus.Failed {
                            AlertControl.show(self, title: "Compress video", message: "There was a problem compressing the video maybe you can try again later. Error: \(session.error?.localizedDescription)", handler: nil)
                        }
                    })
                })
            }
        } else {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                setImageToSelectedImageView(image, videoFile: nil)
                picker.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onImageTapped(sender: UITapGestureRecognizer) {
        if let iv = sender.view as? UIImageView {
            switch iv {
            case imageView1: selectedImageIndex = 0
            case imageView2: selectedImageIndex = 1
            case imageView3: selectedImageIndex = 2
            default: break
            }
        }
        
        if !imagesAvail[selectedImageIndex] {
            for (index, avail) in imagesAvail.enumerate() {
                if !avail {
                    selectedImageIndex = index
                    break
                }
            }
        }
        
        showActionSheets()
    }
    
    func showActionSheets() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Pick photo from library
        let pickPhotoAction = UIAlertAction(title: "Choose photo from library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.PhotoLibrary, mediaType: .PickPhoto)
        })
        optionMenu.addAction(pickPhotoAction)
        
        let pickVideoAction = UIAlertAction(title: "Choose video from library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.PhotoLibrary, mediaType: .PickVideo)
        })
        optionMenu.addAction(pickVideoAction)
        
        // Take photo/video from camera if camera is avail
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            let takePhotoAction = UIAlertAction(title: "Take photo", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.Camera, mediaType: .TakePhoto)
            })
            optionMenu.addAction(takePhotoAction)
            
            let pickVideoAction = UIAlertAction(title: "Record a 30s video", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                Camera.loadMediaFrom(self, sourceType: UIImagePickerControllerSourceType.Camera, mediaType: .Record30sVideo)
            })
            optionMenu.addAction(pickVideoAction)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
}

// MARK: - DescTextPlaceHolder
extension PostViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var newText: NSString = textView.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: text)
        
        let textLength = newText.length
        descPlaceHolder.hidden = textLength > 0
        
        return true
    }
}

extension PostViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text!
        if textField == priceLabel {
            
            if currentText.characters.count + string.characters.count > priceMaxLength {
                return false
            }
            
            let aSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            return string == numberFiltered
        } else if textField == titleLabel {
            if currentText.characters.count + string.characters.count > titleMaxLength {
                return false
            }
        }
        
        return true
    }
}

// MARK: Send notifications
extension PostViewController {
    func sendNotificationForNewPost(post: Post) {
        var params = [String : AnyObject]()
        params["postId"] = post.objectId!
        params["title"] = post.title
        params["price"] =  post.price.formatVND()
        Notification.sendNotifications(NotificationType.Following, params: params, callback: { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
        })
        
        params["description"] = post.descriptionText
        Notification.sendNotifications(NotificationType.Keywords, params: params) { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
        }
    }
    
    func sendNotificationForUpdatedPost(post: Post, changeDescription: String) {
        if changeDescription.isEmpty {
            return
        }
        var params = [String : AnyObject]()
        params["postId"] = post.objectId!
        params["title"] = post.title
        params["price"] =  post.price.formatVND()
        params["extraInfo"] = changeDescription
        Notification.sendNotifications(NotificationType.SavedPost, params: params, callback: { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
        })
    }
}

// MARK: Handle UI with Keyboard show/hide
extension PostViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        descTextHeight.constant = (UIScreen.mainScreen().bounds.height - descriptionText.frame.origin.y) - keyboardFrame.height - 10
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardHide(notification: NSNotification) {
        descTextHeight.constant = okImageView.frame.origin.y - descriptionText.frame.origin.y - 10
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
}