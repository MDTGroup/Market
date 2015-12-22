//
//  ParentChatViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/21/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD

class ParentChatViewController: UIViewController {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newTagImageView: UIImageView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var profileView: UIView!
    
    var tapGesture: UITapGestureRecognizer!
    
    var conversation: Conversation!
    
    func initControls() {
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        
        let tapPostGesture = UITapGestureRecognizer(target: self, action: "onTapPost:")
        postView.addGestureRecognizer(tapPostGesture)
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: "onTapProfile:")
        profileView.addGestureRecognizer(tapProfileGesture)
    }
    
    func onTapProfile(gesture: UITapGestureRecognizer) {
        let userTimelineVC = UserTimelineViewController.instantiateViewController
        userTimelineVC.user = conversation.post.user
        presentViewController(userTimelineVC, animated: true, completion: nil)
    }
    
    func onTapPost(gesture: UITapGestureRecognizer) {
        let detailVC = DetailViewController.instantiateViewController
        detailVC.post = conversation.post
        presentViewController(detailVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        loadPost()
        
        if let navController = navigationController, messageVC = navController.viewControllers[navController.viewControllers.count - 2] as? MessageViewController {
            messageVC.title = conversation.post.title
        }
        
        if let currentUser = User.currentUser() {
            for user in conversation.users {
                if user.objectId != currentUser.objectId {
                    user.fetchIfNeededInBackgroundWithBlock({ (result, error) -> Void in
                        self.title = user.fullName
                    })
                    break
                }
            }
        }
    }
    
    func loadPost() {
        let post = conversation.post
        
        self.sellerLabel.text = ""
        post.user.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
            if let avatar = post.user.avatar {
                self.avatarImageView.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: {
                    self.avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                    self.avatarImageView.alpha = 1.0
                    }, completion: nil)
            }
            self.sellerLabel.text = post.user.fullName
        }
        
        // Set Item
        if post.medias.count > 0 {
            itemImageView.alpha = 0.0
            UIView.animateWithDuration(0.3, animations: {
                self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
                self.itemImageView.alpha = 1.0
                }, completion: nil)
        }
        
        itemNameLabel.text = post.title
        timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
        priceLabel.text = post.price.formatCurrency()
        newTagImageView.hidden = (post.condition > 0)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ChatViewController {
            chatVC.conversation = conversation
        }
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            if let navController = navigationController {
                for vc in navController.viewControllers {
                    if let messageVC = vc as? MessageViewController {
                        messageVC.post = conversation.post
                        break
                    }
                }
            }
        }
    }
}

extension ParentChatViewController {
    static func show(post: Post) {
        if let currentUser = User.currentUser() {
            if post.user.objectId == currentUser.objectId {
                print("Cannot message your self")
                return
            }
        }
        
        if let tabBarController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? UITabBarController {
            let storyboard = UIStoryboard(name: "Messages", bundle: nil)
            if let messageVC = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.messageViewController) as? MessageViewController,
                parentChatVC = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.chatViewController) as? ParentChatViewController {

                var view = tabBarController.view
                if let navController = tabBarController.selectedViewController as? UINavigationController,
                    visibleViewController = navController.visibleViewController {
                    view = visibleViewController.view
                }
                
                let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
                hud.labelText = "Opening chat..."
                Conversation.addConversation(post.user, post: post, callback: { (conversation, error) -> Void in
                    guard error == nil else {
                        hud.hide(true)
                        print(error)
                        return
                    }
                    UIApplication.sharedApplication().delegate?.window!!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
                    if let conversation = conversation {
                        tabBarController.selectedIndex = 1
                        messageVC.post = conversation.post
                        parentChatVC.conversation = conversation
                        parentChatVC.conversation.post.fetchIfNeededInBackgroundWithBlock({ (post, error) -> Void in
                            
                            guard error == nil else {
                                print(error)
                                return
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                hud.hide(true)
                                if let navController = tabBarController.selectedViewController as? UINavigationController {
                                    navController.popToRootViewControllerAnimated(false)
                                    navController.pushViewController(messageVC, animated: false)
                                    navController.pushViewController(parentChatVC, animated: false)
                                }
                            })
                        })
                    } else {
                        hud.hide(true)
                    }
                })
            }
        }
    }
}