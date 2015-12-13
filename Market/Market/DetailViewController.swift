//
//  DetailViewController.swift
//  Market
//
//  Created by Dave Vo on 12/10/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import UIKit
import AFNetworking


class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var buttonsView: UIView!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var voteButton: UIButton!
  @IBOutlet weak var chatButton: UIButton!
  @IBOutlet weak var saveButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var chatButtonWidth: NSLayoutConstraint!
  
  @IBOutlet weak var dimmingView: UIView!
  @IBOutlet weak var dimmingViewHeight: NSLayoutConstraint!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var textHeight: NSLayoutConstraint!
  
  @IBOutlet weak var itemNameLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var cancelButton: UIButton!
  
  @IBOutlet weak var scrollCircle1: UIImageView!
  @IBOutlet weak var scrollCircle2: UIImageView!
  @IBOutlet weak var scrollCircle3: UIImageView!
  
  var post: Post!
  var isReadingFullDescription: Bool!
  var tapGesture: UITapGestureRecognizer!
  var imagePanGesture: UIPanGestureRecognizer!
  var selectedImage = 1
  var nImages: Int = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    itemNameLabel.text = post.title
    descriptionText.text = post.descriptionText
    descriptionText.selectable = false
    
    // Create the "padding" for the text
    descriptionText.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10)
    isReadingFullDescription = false
    showDescription(UIScreen.mainScreen().bounds.height - 140, bgAlpha: 0.1)
    
    // Just set the bg color's alpha
    // Don't set the view's alpha else the subView will inherit it
    buttonsView.layer.borderWidth = 0.5
    buttonsView.layer.borderColor = UIColor.grayColor().CGColor
    dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    tapGesture = UITapGestureRecognizer(target: self, action: "showMore:")
    view.addGestureRecognizer(tapGesture)
    
    // Load the thumbnail first for user to see while waiting for loading the full image
    imageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
    imageView.setImageWithURL(NSURL(string: post.medias[1].url!)!)
    imagePanGesture = UIPanGestureRecognizer(target: self, action: "changeImage:")
    imageView.addGestureRecognizer(imagePanGesture)
    
    nImages = post.medias.count - 1
    scrollCircle1.hidden = nImages < 2
    scrollCircle2.hidden = nImages < 2
    scrollCircle3.hidden = nImages < 3
    
    // Set the buttons width equally
    let w = UIScreen.mainScreen().bounds.width
    saveButtonWidth.constant = w / 3
    chatButtonWidth.constant = w / 3
    
    // Set the images scroll indicator
    setImageScroll(1)
    
    // Indicate network status
    //    if Helper.hasConnectivity() {
    //      showNoNetwork(invisiblePosition)
    //    } else {
    //      showNoNetwork(visiblePosition)
    //    }
  }
  
  func setImageScroll(selected: Int) {
    scrollCircle1.layer.cornerRadius = 4
    scrollCircle1.clipsToBounds = true
    scrollCircle2.layer.cornerRadius = 4
    scrollCircle2.clipsToBounds = true
    scrollCircle3.layer.cornerRadius = 4
    scrollCircle3.clipsToBounds = true
    
    switch selected {
    case 1:
      scrollCircle1.backgroundColor = MyColors.bluesky
      scrollCircle2.backgroundColor = UIColor.lightGrayColor()
      scrollCircle3.backgroundColor = UIColor.lightGrayColor()
    case 2:
      scrollCircle1.backgroundColor = UIColor.lightGrayColor()
      scrollCircle2.backgroundColor = MyColors.bluesky
      scrollCircle3.backgroundColor = UIColor.lightGrayColor()
    case 3:
      scrollCircle1.backgroundColor = UIColor.lightGrayColor()
      scrollCircle2.backgroundColor = UIColor.lightGrayColor()
      scrollCircle3.backgroundColor = MyColors.bluesky
    default:
      return
    }
  }
  
  func showMore(gesture: UITapGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.Ended {
      let tapLocation = gesture.locationInView(self.view)
      if tapLocation.y >= dimmingView.frame.origin.y {
        if !isReadingFullDescription {
          isReadingFullDescription = true
          showDescription(55, bgAlpha: 0.9)
        } else {
          isReadingFullDescription = false
          showDescription(UIScreen.mainScreen().bounds.height - 140, bgAlpha: 0.1)
        }
      }
    }
  }
  
  func changeImage(sender: UIPanGestureRecognizer) {
    let velocity    = sender.velocityInView(view)
    //let translation = sender.translationInView(view)
    
    if sender.state == UIGestureRecognizerState.Began {
      
    } else if sender.state == UIGestureRecognizerState.Changed {
      
    } else if sender.state == UIGestureRecognizerState.Ended {
      if velocity.x < 0 {
        selectedImage += 1
        if selectedImage > nImages {
          selectedImage = 1
        }
      } else {
        selectedImage -= 1
        if selectedImage < 1 {
          selectedImage = nImages
        }
      }
      imageView.setImageWithURL(NSURL(string: post.medias[selectedImage].url!)!)
      setImageScroll(selectedImage)
    }
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // This can detect the tap, but the scroll will be recognized as tap as well :(
  //  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
  //    let touch = touches.first
  //    let touchLocation = touch!.locationInView(self.view)
  //    if touchLocation.y >= dimmingView.frame.origin.y {
  //      if !isReadingFullDescription {
  //        isReadingFullDescription = true
  //        showSynopsis(65, bgAlpha: 0.7)
  //      } else {
  //        isReadingFullDescription = false
  //        showSynopsis(UIScreen.mainScreen().bounds.height - 100, bgAlpha: 0.1)
  //      }
  //    }
  //  }
  
  func showDescription(y: CGFloat, bgAlpha: CGFloat) {
    let dimmingHeight = UIScreen.mainScreen().bounds.height - y - 40
    dimmingViewHeight.constant = dimmingHeight
    // The size of the textView to fit its content
    let newSize = self.descriptionText.sizeThatFits(CGSize(width: self.descriptionText.frame.width, height: CGFloat.max))
    
    dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: bgAlpha)
    textHeight.constant = min(dimmingHeight - 8, newSize.height)
    
    UIView.animateWithDuration(0.4) {
      self.view.layoutIfNeeded()
    }
  }
  
  @IBAction func onCancel(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func onSaveTapped(sender: UIButton) {
    post.save(true) { (successful: Bool, error: NSError?) -> Void in
      if successful {
        print("saved")
      } else {
        print("failed to save")
      }
    }
  }
  
  @IBAction func onVoteTapped(sender: UIButton) {
    post.vote(true) { (successful: Bool, error: NSError?) -> Void in
      if successful {
        print("voted")
      } else {
        print("failed to vote")
      }
    }
  }
  
}
