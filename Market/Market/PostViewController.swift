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
  
  @IBOutlet weak var priceLabel: UITextField!
  @IBOutlet weak var conditionSegment: UISegmentedControl!
  
  @IBOutlet weak var titleLabel: UITextField!
  @IBOutlet weak var descriptionText: UITextView!
  
  @IBOutlet var iv1SingleTap: UITapGestureRecognizer!
  @IBOutlet var iv2SingleTap: UITapGestureRecognizer!
  @IBOutlet var iv3SingleTap: UITapGestureRecognizer!
  
  @IBOutlet var iv1DoubleTap: UITapGestureRecognizer!
  @IBOutlet var iv2DoubleTap: UITapGestureRecognizer!
  @IBOutlet var iv3DoubleTap: UITapGestureRecognizer!
  
  var currentGeoPoint: PFGeoPoint?
  var selectedImageIndex: Int = 0
  var imagesAvail = [Bool](count: 3, repeatedValue: false)
  
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
  
  @IBAction func onPostTapped(sender: UIButton) {
    savePost()
  }
  
  func savePost() {
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
    
    if images.count == 0 {
      // Allow post without image?
      let alertController = UIAlertController(title: "Market", message: "Please add image", preferredStyle: .Alert)
      
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
      alertController.addAction(okAction)
      presentViewController(alertController, animated: true, completion: nil)
      return
    }
    
    let post = Post()
    var image = resizeImage(images[0], newWidth: 1200)
    let thumbnails = resizeImage(image, newWidth: 150)
    var imageFile = PFFile(name: "img1.jpg", data: UIImageJPEGRepresentation(image, 0.4)!)
    let thumbnailsFile = PFFile(name: "thumb.jpg", data: UIImageJPEGRepresentation(thumbnails, 0.4)!)
    post.medias = [thumbnailsFile!, imageFile!]
    
    if images.count > 1 {
      for i in 1...images.count-1 {
        image = resizeImage(images[i], newWidth: 1200)
        imageFile = PFFile(name: "img\(i+1).jpg", data: UIImageJPEGRepresentation(image, 0.4)!)
        post.medias.append(imageFile!)
      }
    }
    
    post.title = titleLabel.text!
    post.price = Double(priceLabel.text!)!
    post.condition = conditionSegment.selectedSegmentIndex // 0 = new
    post.sold = false
    post.descriptionText = descriptionText.text
    post.location = currentGeoPoint
    post.isDeleted = false
    post.saveWithCallbackProgressAndFinish({ (post: Post) -> Void in
      print(post)
      self.delegate?.postViewController?(self, didUploadNewPost: post)
      self.tabBarController!.selectedIndex = 0
      
      }) { (post: Post, percent: Float) -> Void in
        print(percent)
    }
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    if image.size.width <= newWidth {
      return image
    }
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  @IBAction func omRemoveImage1(sender: UIButton) {
    initImageFrame(imageView1)
    imagesAvail[0] = false
  }
  
  @IBAction func onRemoveImage2(sender: UIButton) {
    initImageFrame(imageView2)
    imagesAvail[1] = false
  }
  
  @IBAction func onRemoveImage3(sender: UIButton) {
    initImageFrame(imageView3)
    imagesAvail[2] = false
  }
  
  @IBAction func onDiscard(sender: UIButton) {
    self.tabBarController!.selectedIndex = 0
  }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    // User selected an image
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
