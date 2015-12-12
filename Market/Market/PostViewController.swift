//
//  PostViewController.swift
//  Market
//
//  Created by Dave Vo on 12/12/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController {
  
  @IBOutlet weak var imageView1: UIImageView!
  
  @IBOutlet weak var priceLabel: UITextField!
  @IBOutlet weak var conditionSegment: UISegmentedControl!
  
  @IBOutlet weak var titleLabel: UITextField!
  @IBOutlet weak var descriptionText: UITextView!
  
  var currentGeoPoint: PFGeoPoint?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    getCurrentLocation()
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
    let image = imageView1.image
    let thumbnails = resizeImage(image!, newWidth: 150)
    let imageFile = PFFile(name: "img1.png", data: UIImagePNGRepresentation(image!)!)!
    let thumbnailsFile = PFFile(name: "img1-thumbs.png", data: UIImagePNGRepresentation(thumbnails)!)!
    
    let post = Post()
    post.medias = [thumbnailsFile, imageFile]
    
    post.title = titleLabel.text!
    post.price = Double(priceLabel.text!)!
    post.condition = conditionSegment.selectedSegmentIndex // 0 = new
    post.sold = false
    post.descriptionText = descriptionText.text
    post.location = currentGeoPoint
    post.isDeleted = false
    post.saveWithCallbackProgressAndFinish({ (post: Post) -> Void in
      print(post)
      self.tabBarController!.selectedIndex = 0
      
      }) { (post: Post, percent: Float) -> Void in
        print(percent)
    }
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    // User selected an image
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.imageView1.image = image
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    // User cancel the image picker
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func onAddMedia(sender: UIButton) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    self.presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func onTakePic(sender: UIButton) {
    if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
      self.presentViewController(imagePicker, animated: true, completion: nil)
    }
  }
  
  @IBAction func onDiscard(sender: UIButton) {
    self.tabBarController!.selectedIndex = 0
  }
  
}