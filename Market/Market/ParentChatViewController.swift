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
    @IBOutlet weak var postContentView: UIView!
    @IBOutlet weak var priceBackgroundView: UIView!
    
    var tapGesture: UITapGestureRecognizer!
    
    var conversation: Conversation!
    
    func initControls() {
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.clipsToBounds = true
        priceBackgroundView.layer.cornerRadius = 5
        priceBackgroundView.clipsToBounds = true
        
        let tapPostGesture = UITapGestureRecognizer(target: self, action: "onTapPost:")
        postView.addGestureRecognizer(tapPostGesture)
        conversation.post.fetchIfNeededInBackgroundWithBlock { (post, error) -> Void in
            if let post = post as? Post {
                post.user.fetchIfNeededInBackgroundWithBlock { (user, error) -> Void in
                    if let currentUser = User.currentUser(), user = user as? User where user.objectId != currentUser.objectId {
                        let tapProfileGesture = UITapGestureRecognizer(target: self, action: "onTapProfile:")
                        self.profileView.addGestureRecognizer(tapProfileGesture)
                    }
                }
            }
        }
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
        
        if let currentUser = User.currentUser() {
            for userId in conversation.userIds where userId != currentUser.objectId! {
                let user = User(withoutDataWithObjectId: userId)
                user.fetchIfNeededInBackgroundWithBlock({ (result, error) -> Void in
                    self.title = user.fullName
                })
                break
            }
        }
    }
    
    func loadPost() {
        conversation.post.fetchIfNeededInBackgroundWithBlock { (post, error) -> Void in
            if let post = post as? Post {
                self.sellerLabel.text = ""
                post.user.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                    if let avatar = post.user.avatar, url = avatar.url {
                        self.avatarImageView.setImageWithURL(NSURL(string: url)!)
                    }
                    self.sellerLabel.text = post.user.fullName
                }
                
                if post.medias.count > 0 {
                    self.itemImageView.setImageWithURL(NSURL(string: post.medias[0].url!)!)
                }
                
                self.itemNameLabel.text = post.title
                self.timeAgoLabel.text = Helper.timeSinceDateToNow(post.updatedAt!)
                self.priceLabel.text = post.price.formatCurrency()
                self.newTagImageView.hidden = post.condition > 0
                if let navController = self.navigationController, messageVC = navController.viewControllers[navController.viewControllers.count - 2] as? MessageViewController {
                    messageVC.title = post.title
                }
            }
        }
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
                        messageVC.title = conversation.post.title
                        messageVC.post = conversation.post
                        break
                    }
                }
            }
        }
    }
}

extension ParentChatViewController {
    static func show(post: Post, fromUser: User, toUser: User) {
        if fromUser.objectId == toUser.objectId {
            print("Cannot chat your self")
            return
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
                Conversation.addConversation(fromUser, toUser: toUser, post: post, callback: { (conversation, error) -> Void in
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