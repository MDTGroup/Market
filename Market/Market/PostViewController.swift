//
//  PostViewController.swift
//  Market
//
//  Created by Dave Vo on 12/12/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import Parse

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
    @IBOutlet weak var quickPostButton: UIButton!
    
    
    @IBOutlet weak var progressBarLength: NSLayoutConstraint!
    @IBOutlet weak var progressBarLeft: NSLayoutConstraint!
    @IBOutlet weak var quickPostLeft: NSLayoutConstraint!
    
    @IBOutlet var iv1SingleTap: UITapGestureRecognizer!
    @IBOutlet var iv2SingleTap: UITapGestureRecognizer!
    @IBOutlet var iv3SingleTap: UITapGestureRecognizer!
    
    @IBOutlet var iv1DoubleTap: UITapGestureRecognizer!
    @IBOutlet var iv2DoubleTap: UITapGestureRecognizer!
    @IBOutlet var iv3DoubleTap: UITapGestureRecognizer!
    
    var currentGeoPoint: PFGeoPoint?
    var selectedImageIndex: Int = 0
    var imagesAvail = [Bool](count: 3, repeatedValue: false)
    var editingPost: Post?
    var isUpdating = false
    var isMediaChanged = false
    
    weak var delegate: PostViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Determine screen size
        let screenWidth = UIScreen.mainScreen().bounds.width
        imageWidth.constant = screenWidth > 350 ? 100: 90
        imageHeight.constant = imageWidth.constant
        
        iv1SingleTap.requireGestureRecognizerToFail(iv1DoubleTap)
        iv2SingleTap.requireGestureRecognizerToFail(iv2DoubleTap)
        iv3SingleTap.requireGestureRecognizerToFail(iv3DoubleTap)
        
        initImageFrame(imageView1)
        initImageFrame(imageView2)
        initImageFrame(imageView3)
        
        getCurrentLocation()
        
        if editingPost != nil {
            title = "Update the item"
            isUpdating = true
            loadPostToUpdate()
            navBar.rightBarButtonItem = UIBarButtonItem(title: "Update", style: UIBarButtonItemStyle.Plain, target: self, action: "updatePost")
        } else {
            title = "Post new item"
            isUpdating = false
            navBar.rightBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: "newPost")
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
        progressBarLeft.constant = 70
        progressBarLength.constant = UIScreen.mainScreen().bounds.width - 70 - 25
        quickPostLeft.constant = (UIScreen.mainScreen().bounds.width - 50) / 2
        
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
        descTextHeight.constant = quickPostButton.frame.origin.y - descriptionText.frame.origin.y - 10
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func loadPostToUpdate() {
        priceLabel.text = "\((editingPost?.price)!)"
        titleLabel.text = editingPost?.title
        descriptionText.text = editingPost?.descriptionText
        descPlaceHolder.hidden = true
        conditionSegment.selectedSegmentIndex = (editingPost?.condition)!
        
        let nImages = editingPost?.medias.count
        
        imageView1.image = UIImage(named: "loading")
        imageView1.setImageWithURL(NSURL(string: (editingPost?.medias[1].url!)!)!)
        imageView1.contentMode = .ScaleAspectFill
        removeButton1.hidden = false
        imagesAvail[0] = true
        
        if nImages > 2 {
            imageView1.image = UIImage(named: "loading")
            imageView2.setImageWithURL(NSURL(string: (editingPost?.medias[2].url!)!)!)
            imageView2.contentMode = .ScaleAspectFill
            removeButton2.hidden = false
            imagesAvail[1] = true
        }
        
        if nImages > 3 {
            imageView1.image = UIImage(named: "loading")
            imageView3.setImageWithURL(NSURL(string: (editingPost?.medias[3].url!)!)!)
            imageView3.contentMode = .ScaleAspectFill
            removeButton3.hidden = false
            imagesAvail[2] = true
        }
    }
    
    func initImageFrame(iv: UIImageView) {
        iv.layer.borderColor = MyColors.bluesky.CGColor
        iv.layer.borderWidth = 0.5
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.image = UIImage(named: "camera")
        iv.contentMode = .Center
        
        switch iv {
        case imageView1: removeButton1.hidden = true
        case imageView2: removeButton2.hidden = true
        case imageView3: removeButton3.hidden = true
        default: break
        }
    }
    
    func setImageToSelectedImageView(image: UIImage) {
        switch selectedImageIndex {
        case 1:
            imageView1.image = image
            imageView1.contentMode = .ScaleAspectFill
            removeButton1.hidden = false
        case 2:
            imageView2.image = image
            imageView2.contentMode = .ScaleAspectFill
            removeButton2.hidden = false
        case 3:
            imageView3.image = image
            imageView3.contentMode = .ScaleAspectFill
            removeButton3.hidden = false
        default: break
        }
        imagesAvail[selectedImageIndex-1] = true
    }
    
    func tapOnImage(gesture: UITapGestureRecognizer) {
        if let iv = gesture.view as? UIImageView {
            switch iv {
            case imageView1: selectedImageIndex = 1
            case imageView2: selectedImageIndex = 2
            case imageView3: selectedImageIndex = 3
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
            let alertController = UIAlertController(title: "Market", message: "Please add image", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
            return nil
        }
        
        if priceLabel.text! == "" {
            let alertController = UIAlertController(title: "Market", message: "Please enter the price", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: { () -> Void in
                self.priceLabel.becomeFirstResponder()
            })
            return nil
        }
        
        if titleLabel.text! == "" {
            let alertController = UIAlertController(title: "Market", message: "Please enter the title", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: { () -> Void in
                self.titleLabel.becomeFirstResponder()
            })
            return nil
        }
        
        if descriptionText.text! == "" {
            let alertController = UIAlertController(title: "Market", message: "Please enter the description", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: { () -> Void in
                self.descriptionText.becomeFirstResponder()
            })
            return nil
        }
        
        // Collect info
        var image = Helper.resizeImage(images[0], newWidth: 1600)
        let thumbnails = Helper.resizeImage(image, newWidth: 750)
        var imageFile = PFFile(name: "img1.jpg", data: UIImageJPEGRepresentation(image, 0.4)!)
        let thumbnailsFile = PFFile(name: "thumb.jpg", data: UIImageJPEGRepresentation(thumbnails, 0.2)!)
        post.medias = [thumbnailsFile!, imageFile!]
        
        if images.count > 1 {
            for i in 1...images.count-1 {
                image = Helper.resizeImage(images[i], newWidth: 1200)
                imageFile = PFFile(name: "img\(i+1).jpg", data: UIImageJPEGRepresentation(image, 0.4)!)
                post.medias.append(imageFile!)
            }
        }
        
        post.title = titleLabel.text!
        post.price = Double(priceLabel.text!)!
        post.condition = conditionSegment.selectedSegmentIndex // 0 = new
        
        post.descriptionText = descriptionText.text
        post.location = currentGeoPoint
        
        post.vote = Vote()
        
        return post
    }
    
    func newPost() {
        if let post = preparePost() {
            showProgressBar()
            // Set these initial values only for new post
            post.sold = false
            post.isDeleted = false
            post.voteCounter = 0
            post.vote = Vote()
            post.saveWithCallbackProgressAndFinish({ (post: Post) -> Void in
                print(post)
                self.delegate?.postViewController?(self, didUploadNewPost: post)
                self.tabBarController!.selectedIndex = 0
                
                }) { (post: Post, percent: Float) -> Void in
                    print(percent)
                    self.progressBar.setProgress(percent, animated: true)
            }
        }
    }
    
    func updatePost() {
        print("updating post")
        if let newPost = preparePost() {
            showProgressBar()
            let post = Post(withoutDataWithObjectId: (editingPost?.objectId)!)
            post.fetchInBackgroundWithBlock { (fetchedPFObj, error) -> Void in
                print(fetchedPFObj)
                if let fetchedPost = fetchedPFObj as? Post {
                    fetchedPost.title = newPost.title
                    fetchedPost.descriptionText = newPost.descriptionText
                    fetchedPost.price = newPost.price
                    fetchedPost.condition = newPost.condition
                    if self.isMediaChanged {
                        fetchedPost.medias = newPost.medias
                    }
                    fetchedPost.sold = newPost.sold
                    
                    fetchedPost.saveWithCallbackProgressAndFinish({ (post: Post) -> Void in
                        self.delegate?.postViewController?(self, didUploadNewPost: post)
                        self.dismissViewControllerAnimated(true, completion: nil)
                        }) { (post: Post, percent: Float) -> Void in
                            print(percent)
                            self.progressBar.setProgress(percent, animated: true)
                    }
                } else {
                    print("Not able to update post :(")
                }
            }
            
        }
    }
    
    func showProgressBar() {
        view.endEditing(true)
        self.quickPostLeft.constant = 25
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
            self.progressBar.alpha = 1
        }
    }
    
    @IBAction func onQuickPost(sender: UIButton) {
        if isUpdating {
            updatePost()
        } else {
            newPost()
        }
    }
    
    @IBAction func onRemoveImage1(sender: UIButton) {
        isMediaChanged = true
        initImageFrame(imageView1)
        imagesAvail[0] = false
    }
    
    @IBAction func onRemoveImage2(sender: UIButton) {
        isMediaChanged = true
        initImageFrame(imageView2)
        imagesAvail[1] = false
    }
    
    @IBAction func onRemoveImage3(sender: UIButton) {
        isMediaChanged = true
        initImageFrame(imageView3)
        imagesAvail[2] = false
    }
    
    @IBAction func onDismiss(sender: UIBarButtonItem) {
        if isUpdating {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.tabBarController!.selectedIndex = 0
        }
    }
    
}

// MARK: - Image Picker
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // User selected an image
        isMediaChanged = true
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setImageToSelectedImageView(image)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // User cancel the image picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadImageFrom(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onImageTapped(sender: UITapGestureRecognizer) {
        if let iv = sender.view as? UIImageView {
            switch iv {
            case imageView1: selectedImageIndex = 1
            case imageView2: selectedImageIndex = 2
            case imageView3: selectedImageIndex = 3
            default: break
            }
        }
        
        loadImageFrom(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func onImageDoubleTapped(sender: UITapGestureRecognizer) {
        if let iv = sender.view as? UIImageView {
            switch iv {
            case imageView1: selectedImageIndex = 1
            case imageView2: selectedImageIndex = 2
            case imageView3: selectedImageIndex = 3
            default: break
            }
        }
        print("take pic for img \(selectedImageIndex)")
        
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            loadImageFrom(UIImagePickerControllerSourceType.Camera)
        }
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