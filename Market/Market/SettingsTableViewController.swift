//
//  SettingsTableViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/11/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var imagePickerView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        
        if let currentUser = User.currentUser() {
            self.fullnameLabel.text = currentUser.fullName
            
            //load avatar
            if let imageFile = currentUser.avatar {
                imageFile.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                    self.imagePickerView.image = UIImage(data: data!)
                }
            } else {
                print("User has not profile picture")
            }
        }
        
    }
    
    func initControls() {
        self.imagePickerView.layer.cornerRadius = self.imagePickerView.frame.size.width / 2
        self.imagePickerView.clipsToBounds = true
    }
    
    @IBAction func onCloseSettings(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.logOut()
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
