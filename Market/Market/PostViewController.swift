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
    
    var currentGeoPoint: PFGeoPoint?
    var selectedImageIndex: Int = 0
    var imagesAvail = [Bool](count: 3, repeatedValue: false)
    var editingPost: Post?
    var isUpdating = false
    var isMediaChanged = false
    var tapGestureOnInstruction: UIGestureRecognizer!
    var videoURL: NSURL?
    var videoPosition: Int = -1 // 0 means yet to set
    var videoPFFile: PFFile?
    
    let priceMaxLength = 13
    let titleMaxLength = 140
    
    weak var delegate: PostViewControllerDelegate?
    
    var isSubmittingNewPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Determine screen size
        let screenWidth = UIScreen.mainScreen().bounds.width
        imageWidth.constant = screenWidth > 350 ? 100: 90
        imageHeight.constant = imageWidth.constant
        
        initImageFrame(imageView1)
        initImageFrame(imageView2)
        initImageFrame(imageView3)
        
        priceLabel.delegate = self
        titleLabel.delegate = self
        
        getCurrentLocation()
        
        if editingPost != nil {
            title = "Update the item"
            isUpdating = true
            loadPostToUpdate()
            navBar.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: .Plain, target: self, action: "updatePost")
        } else {
            title = "Post new item"
            isUpdating = false
            navBar.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: .Plain, target: self, action: "newPost")
        }
        //discardButton.hidden = isUpdating
        //draftButton.hidden = isUpdating
        //postButton.hidden = isUpdating
        
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
        
        // Add observer to detect when the keyboard will be shown/hide
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        priceLabel.becomeFirstResponder()
    }
    
    func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        print("keyboardFrame: \(keyboardFrame)")
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
    
    //    func hideInstruction() {
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
    //    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func loadPostToUpdate() {
        priceLabel.text = "\(Int((editingPost?.price)!))"
        titleLabel.text = editingPost?.title
        descriptionText.text = editingPost?.descriptionText
        descPlaceHolder.hidden = true
        conditionSegment.selectedSegmentIndex = (editingPost?.condition)!
        
        let nImages = (editingPost?.medias.count)! / 2
        var url = editingPost?.medias[nImages].url!
        
        imageView1.image = UIImage(named: "loading")
        if (url?.rangeOfString("video.mov") != nil) {
            // If this is video then use the thumbnail
            url = editingPost?.medias[0].url!
            imageView1.setImageWithURL(NSURL(string: url!)!)
            videoPosition = 0
            videoPFFile = editingPost?.medias[nImages]
            videoImage1.hidden = false
            print("video at 0")
        } else {
            imageView1.setImageWithURL(NSURL(string: url!)!)
        }
        imageView1.contentMode = .ScaleAspectFill
        removeButton1.hidden = false
        imagesAvail[0] = true
        
        // Check 2nd image
        if nImages > 1 {
            imageView2.image = UIImage(named: "loading")
            url = editingPost?.medias[nImages+1].url!
            if (url?.rangeOfString("video.mov") != nil) {
                // If this is video then use the thumbnail
                url = editingPost?.medias[1].url!
                imageView2.setImageWithURL(NSURL(string: url!)!)
                videoPosition = 1
                videoPFFile = editingPost?.medias[nImages+1]
                videoImage2.hidden = false
                print("video at 1")
            } else {
                imageView2.setImageWithURL(NSURL(string: url!)!)
            }
            imageView2.contentMode = .ScaleAspectFill
            removeButton2.hidden = false
            imagesAvail[1] = true
        }
        
        // Check 3rd image
        if nImages > 2 {
            imageView3.image = UIImage(named: "loading")
            url = editingPost?.medias[nImages+2].url!
            if (url?.rangeOfString("video.mov") != nil) {
                // If this is video then use the thumbnail
                url = editingPost?.medias[2].url!
                imageView3.setImageWithURL(NSURL(string: url!)!)
                videoPosition = 2
                videoPFFile = editingPost?.medias[nImages+2]
                videoImage3.hidden = false
                print("video at 2")
            } else {
                imageView3.setImageWithURL(NSURL(string: url!)!)
            }
            imageView3.contentMode = .ScaleAspectFill
            removeButton3.hidden = false
            imagesAvail[2] = true
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
    
    func setImageToSelectedImageView(image: UIImage, isVideo: Bool) {
        switch selectedImageIndex {
        case 0:
            imageView1.image = image
            imageView1.contentMode = .ScaleAspectFill
            removeButton1.hidden = false
            videoImage1.hidden = !isVideo
        case 1:
            imageView2.image = image
            imageView2.contentMode = .ScaleAspectFill
            removeButton2.hidden = false
            videoImage3.hidden = !isVideo
        case 2:
            imageView3.image = image
            imageView3.contentMode = .ScaleAspectFill
            removeButton3.hidden = false
            videoImage3.hidden = !isVideo
        default: break
        }
        imagesAvail[selectedImageIndex] = true
    }
    
    func tapOnImage(gesture: UITapGestureRecognizer) {
        if let iv = gesture.view as? UIImageView {
            switch iv {
            case imageView1: selectedImageIndex = 0
            case imageView2: selectedImageIndex = 1
            case imageView3: selectedImageIndex = 2
            default: break
            }
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Disable landscape mode in this view
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // MARK: Get current location
    func getCurrentLocation() {
        PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.currentGeoPoint = geoPoint
        })
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
            // Allow post without image?
            AlertControl.show(self, title: "Market", message: "Please add image", handler: nil)
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
        post.location = currentGeoPoint
        
        post.vote = Vote()
        
        // Media:
        // 0..nImages-1: thumbnails
        // nImage..2*nImages-1: images
        var image: UIImage!
        var imageFile: PFFile!
        
        // Attach thumbnails
        for i in 0...images.count-1 {
            image = Helper.resizeImage(images[i], newWidth: 750)
            imageFile = PFFile(name: "thumb\(i+1).jpg", data: UIImageJPEGRepresentation(image, 0.2)!)
            post.medias.append(imageFile!)
        }
        // Attach image/video
        for i in 0...images.count-1 {
            if i == videoPosition {
                post.medias.append(videoPFFile!)
            } else {
                image = Helper.resizeImage(images[i], newWidth: 1600)
                imageFile = PFFile(name: "img\(i+1).jpg", data: UIImageJPEGRepresentation(image, 0.4)!)
                post.medias.append(imageFile!)
            }
        }
        
        // TODO: Compress video
        //        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        //        let recordingName = "drm.mov"
        //        let pathArray = [dirPath, recordingName]
        //        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        //        print(filePath)
        //
        //        if videoPosition > 0 {
        //            Helper.compressVideo(videoURL!, outputURL: filePath!) { (session) -> Post in
        //                if session.status == .Completed {
        //                    let data = NSData(contentsOfURL: filePath!)
        //                    print("File size after compression: \(Double(data!.length / 1024)) kb")
        //                    let videoFile = PFFile(name: "video.mov", data: NSData(data: data!))
        //                    post.medias.append(videoFile!)
        //                    return post
        //                } else if session.status == .Failed {
        //                    print("failed to compress video")
        //                }
        //                return post
        //            }
        //        } else {
        //            return post
        //        }
        
        return post
    }
    
    func resetPostPage() {
        initImageFrame(imageView1)
        initImageFrame(imageView2)
        initImageFrame(imageView3)
        priceLabel.text = ""
        descriptionText.text = ""
        titleLabel.text = ""
        progressBar.setProgress(0, animated: false)
        progressBar.alpha = 0
        okImageView.alpha = 0
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
                    
                    if self.isMediaChanged {
                        fetchedPost.medias = newPost.medias
                        changeDescription += "media"
                    }
                    
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
        isMediaChanged = true
        initImageFrame(imageView1)
        imagesAvail[0] = false
        if videoPosition == 0 {
            videoPosition = -1
        }
    }
    
    @IBAction func onRemoveImage2(sender: UIButton) {
        isMediaChanged = true
        initImageFrame(imageView2)
        imagesAvail[1] = false
        if videoPosition == 1 {
            videoPosition = -1
        }
    }
    
    @IBAction func onRemoveImage3(sender: UIButton) {
        isMediaChanged = true
        initImageFrame(imageView3)
        imagesAvail[2] = false
        if videoPosition == 2 {
            videoPosition = -1
        }
    }
    
    @IBAction func onDismiss(sender: UIBarButtonItem) {
        if isUpdating {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.tabBarController!.selectedIndex = 0
        }
    }
    
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

// MARK: - Image Picker
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType == kUTTypeMovie {
            if videoPosition >= 0 {
                AlertControl.show(self, title: "Market", message: "You can't post more than 1 video", handler: nil)
            } else {
                videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
                let data = NSData(contentsOfURL: videoURL!)
                if let data = data where data.length >= 10000 {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    AlertControl.show(self, title: "File size", message: "You cannot upload video with file size >= 10 mb. Please choose a shorter video.", handler: nil)
                    return
                }
                
                isMediaChanged = true
                videoPosition = selectedImageIndex
                // Get the thumbnail of video
                
                print(videoURL)
                let asset = AVAsset(URL: videoURL!)
                let assetImgGenerate = AVAssetImageGenerator(asset: asset)
                assetImgGenerate.appliesPreferredTrackTransform = true
                let time = CMTimeMake(asset.duration.value / 3, asset.duration.timescale)
                if let cgImage = try? assetImgGenerate.copyCGImageAtTime(time, actualTime: nil) {
                    let image = UIImage(CGImage: cgImage)
                    setImageToSelectedImageView(image, isVideo: true)
                }
               
                print("File size: \(Double(data!.length / 1024)) kb")
                
                videoPFFile = PFFile(name: "video.mov", data: NSData(data: data!))
            }
            
        } else {
            // User selected an image
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                isMediaChanged = true
                setImageToSelectedImageView(image, isVideo: false)
                if selectedImageIndex == videoPosition {
                    // User select another image to replace the video
                    videoPosition = -1
                }
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // User cancel the image picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadImageFrom(source: UIImagePickerControllerSourceType, pickVideo: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        //imagePicker.allowsEditing = true
        if pickVideo {
            imagePicker.mediaTypes = [kUTTypeMovie as String]
        } else {
            imagePicker.mediaTypes = [kUTTypeImage as String]
        }
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
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
        
        showActionSheets()
    }
    
    func showActionSheets() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Pick photo from library
        let pickPhotoAction = UIAlertAction(title: "Choose photo from library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.loadImageFrom(UIImagePickerControllerSourceType.PhotoLibrary, pickVideo: false)
            print("Select photo")
        })
        optionMenu.addAction(pickPhotoAction)
        
        // Pick video from library if hasn't picked any, or user want to modify this video
        if (videoPosition < 0) || (videoPosition == selectedImageIndex) {
            let pickVideoAction = UIAlertAction(title: "Choose video from library", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.loadImageFrom(UIImagePickerControllerSourceType.PhotoLibrary, pickVideo: true)
                print("Select video")
            })
            optionMenu.addAction(pickVideoAction)
        }
        
        // Take picture from camera if camera is avail
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            let takePhotoAction = UIAlertAction(title: "Take photo from camera", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Take pic")
                self.loadImageFrom(UIImagePickerControllerSourceType.Camera, pickVideo: false)
            })
            optionMenu.addAction(takePhotoAction)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
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