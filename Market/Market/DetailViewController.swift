//
//  DetailViewController.swift
//  Market
//
//  Created by Dave Vo on 12/10/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol DetailViewControllerDelegate {
  optional func detailViewController(detailViewController: DetailViewController, newPost: Post)
}

class DetailViewController: UIViewController {
  
  @IBOutlet weak var buttonsView: UIView!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var voteButton: UIButton!
  @IBOutlet weak var chatButton: UIButton!
  @IBOutlet weak var voteButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var chatButtonWidth: NSLayoutConstraint!
  
  @IBOutlet weak var dimmingView: UIView!
  @IBOutlet weak var dimmingViewHeight: NSLayoutConstraint!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var textHeight: NSLayoutConstraint!
  @IBOutlet weak var descTextGap: NSLayoutConstraint!
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var sellerLabel: UILabel!
  @IBOutlet weak var updatedAtLabel: UILabel!
  @IBOutlet weak var itemNameLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var cancelButton: UIButton!
  
  @IBOutlet weak var scrollCircle1: UIImageView!
  @IBOutlet weak var scrollCircle2: UIImageView!
  @IBOutlet weak var scrollCircle3: UIImageView!
  
  @IBOutlet weak var voteCountLabel: UILabel!
  @IBOutlet weak var voteLabel: UILabel!
  @IBOutlet var panGesture: UIPanGestureRecognizer!
  
  var post: Post!
  var isReadingFullDescription: Bool!
  var tapGesture: UITapGestureRecognizer!
  //var imagePanGesture: UIPanGestureRecognizer!
  var selectedImage = 1
  var nImages: Int = 1
  var tempImageView1: UIImageView?
  var tempImageView2: UIImageView?
  
  var imageOriginalCenter: CGPoint!
  var direction: CGFloat = 1.0
  
  weak var delegate: DetailViewControllerDelegate?
  
    static let homeSB = UIStoryboard(name: "Home", bundle: nil)
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    itemNameLabel.text = post.title
    descriptionText.text = post.descriptionText
    descriptionText.selectable = false
    
    let formatter = NSDateFormatter()
    formatter.timeStyle = NSDateFormatterStyle.ShortStyle
    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
    updatedAtLabel.text = "Posted on \(formatter.stringFromDate(post.updatedAt!))"
    
    // Create the "padding" for the text
    descriptionText.textContainerInset = UIEdgeInsetsMake(8, 10, 0, 10)
    isReadingFullDescription = false
    
    // Just set the bg color's alpha
    // Don't set the view's alpha else the subView will inherit it
    buttonsView.layer.borderWidth = 0.5
    buttonsView.layer.borderColor = UIColor.grayColor().CGColor
    dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
    showDescription(UIScreen.mainScreen().bounds.height - 140, bgAlpha: 0.0, showFull: false)
    tapGesture = UITapGestureRecognizer(target: self, action: "showMore:")
    view.addGestureRecognizer(tapGesture)
    
    // Load the seller
    post.user.fetchIfNeededInBackgroundWithBlock { (pfObj, error) -> Void in
      guard error == nil else {
        print(error)
        return
      }
      if let user = pfObj as? User {
        self.sellerLabel.text = user.fullName
        if let avatar = user.avatar {
            self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
        }
      }
    }

    avatarImageView.layer.cornerRadius = 18
    avatarImageView.clipsToBounds = true
    
    // Load the thumbnail first for user to see while waiting for loading the full image
    imageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
    imageView.setImageWithURL(NSURL(string: post.medias[1].url!)!)
    //imagePanGesture = UIPanGestureRecognizer(target: self, action: "changeImage:")
    //imageView.addGestureRecognizer(imagePanGesture)
    //imagePanGesture.requireGestureRecognizerToFail(panGesture)
    imageOriginalCenter = imageView.center
    
    nImages = post.medias.count - 1
    scrollCircle1.hidden = nImages < 2
    scrollCircle2.hidden = nImages < 2
    scrollCircle3.hidden = nImages < 3
    
    // Load image while user still redding 1st page
    if nImages > 2 {
      tempImageView1!.setImageWithURL(NSURL(string: post.medias[2].url!)!)
    }
    if nImages > 3 {
      tempImageView2!.setImageWithURL(NSURL(string: post.medias[3].url!)!)
    }
    
    // Set the buttons width equally
    let w = UIScreen.mainScreen().bounds.width
    voteButtonWidth.constant = w / 3
    chatButtonWidth.constant = w / 3
    
    // Set the images scroll indicator
    setImageScroll(1)
    
    // Any posibility if will be nil here?
    self.setSaveLabel(post.iSaveIt!)
    setVoteCountLabel(post.voteCounter, voted: post.iVoteIt!)
    
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
          //descTextGap.constant = 25
          showDescription(54, bgAlpha: 0.9, showFull: true)
          
        } else {
          isReadingFullDescription = false
          //descTextGap.constant = 5
          showDescription(UIScreen.mainScreen().bounds.height - 140, bgAlpha: 0.0, showFull: false)
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
      imageOriginalCenter = imageView.center
      setImageScroll(selectedImage)
    }
  }
  
//  override func prefersStatusBarHidden() -> Bool {
//    return true
//  }
  
  @IBAction func onPanImage(sender: UIPanGestureRecognizer) {
    let translation = sender.translationInView(view)
    let point = sender.locationInView(view)
    
    if sender.state == .Began {
      
      direction = point.y > imageView.frame.height/2 ? -0.15 : 0.15
      
    } else if sender.state == .Changed {
      
      imageView.center = CGPoint(x: imageOriginalCenter.x + translation.x, y: imageOriginalCenter.y)
      
      imageView.transform = CGAffineTransformMakeRotation((direction * translation.x * CGFloat(M_PI)) / 180.0)
    } else if sender.state == .Ended {
      // If drag to right, slide in the (n-1)th image from left
      if translation.x > 50 {
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
          //self.imageView.center = CGPoint(x: 600, y: self.imageOriginalCenter.y)
        })
      } else if translation.x < -50 {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
          //self.imageView.center = CGPoint(x: -300, y: self.imageOriginalCenter.y)
        })
      } else {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
          self.imageView.center = self.imageOriginalCenter
          self.imageView.transform = CGAffineTransformMakeRotation(0)
        })
      }
    }
  }
  
  func showDescription(y: CGFloat, bgAlpha: CGFloat, showFull: Bool) {
    let dimmingHeight = UIScreen.mainScreen().bounds.height - y - 40
    if showFull {
      dimmingViewHeight.constant = dimmingHeight
      view.layoutIfNeeded()
    }
    
    // The size of the textView to fit its content
    let newSize = self.descriptionText.sizeThatFits(CGSize(width: self.descriptionText.frame.width, height: CGFloat.max))
    
    textHeight.constant = min(dimmingHeight - 8, newSize.height)
    descTextGap.constant = showFull ? 25 : 5
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.avatarImageView.alpha = bgAlpha
      self.sellerLabel.alpha = bgAlpha
      self.updatedAtLabel.alpha = bgAlpha
      self.dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: bgAlpha)
      self.view.layoutIfNeeded()
      
      }) { (finished) -> Void in
        // If not showing full description, only reduce the size of dimming view after change the alpha
        if !showFull {
          self.dimmingViewHeight.constant = dimmingHeight
          self.view.layoutIfNeeded()
        }
    }
  }
  
  @IBAction func onCancel(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func onSaveTapped(sender: UIButton) {
    if sender.imageView?.image == UIImage(named: "save_on") {
      // Un-save it
      setSaveLabel(false)
      post.save(false) { (successful: Bool, error: NSError?) -> Void in
        if successful {
          print("unsaved")
          self.post.iSaveIt = false
          self.delegate!.detailViewController!(self, newPost: self.post)
        } else {
          print("failed to unsave")
          self.setSaveLabel(true)
        }
      }
      
    } else {
      // Save it
      setSaveLabel(true)
      post.save(true) { (successful: Bool, error: NSError?) -> Void in
        if successful {
          print("saved")
          self.post.iSaveIt = true
          self.delegate!.detailViewController!(self, newPost: self.post)
        } else {
          print("failed to save")
          self.setSaveLabel(false)
        }
      }
    }
  }
  
  @IBAction func onVoteTapped(sender: UIButton) {
    if sender.imageView?.image == UIImage(named: "thumb_on") {
      // Un-vote it
      let count = Int(self.voteCountLabel.text!)! - 1
      setVoteCountLabel(count, voted: false)
      post.vote(false) { (successful: Bool, error: NSError?) -> Void in
        if successful {
          print("unvoted")
          self.post.iVoteIt = false
          self.delegate!.detailViewController!(self, newPost: self.post)
        } else {
          print("failed to unvote")
          self.setVoteCountLabel(count + 1, voted: true)
        }
      }
      
    } else {
      // Vote it
      let count = Int(self.voteCountLabel.text!)! + 1
      setVoteCountLabel(count, voted: true)
      post.vote(true) { (successful: Bool, error: NSError?) -> Void in
        if successful {
          print("voted")
          self.post.iVoteIt = true
          self.delegate!.detailViewController!(self, newPost: self.post)
        } else {
          print("failed to vote")
          self.setVoteCountLabel(count - 1, voted: false)
        }
      }
    }
  }
  
}

extension DetailViewController {
  func setSaveLabel(saved: Bool) {
    if saved {
      saveButton.setImage(UIImage(named: "save_on"), forState: .Normal)
      saveButton.setTitleColor(MyColors.bluesky, forState: .Normal)
    } else {
      saveButton.setImage(UIImage(named: "save_white"), forState: .Normal)
      saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
  }
  
  func setVoteCountLabel(count: Int, voted: Bool) {
    if voted {
      voteButton.setImage(UIImage(named: "thumb_on"), forState: .Normal)
      voteButton.setTitleColor(MyColors.bluesky, forState: .Normal)
    } else {
      voteButton.setImage(UIImage(named: "thumb_white"), forState: .Normal)
      voteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    voteCountLabel.text = "\(count)"
    voteCountLabel.hidden = !(count > 0)
    voteLabel.hidden = !(count > 0)
  }
}

// MARK: Show view from anywhere
extension DetailViewController {
    static var instantiateViewController: DetailViewController {
        return homeSB.instantiateViewControllerWithIdentifier(StoryboardID.postDetail) as! DetailViewController
    }
}