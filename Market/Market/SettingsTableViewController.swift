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
    
    
    @IBOutlet weak var switchCellSaved: UISwitch!
    @IBOutlet weak var switchCellFollowing: UISwitch!
    @IBOutlet weak var switchCellKeyword: UISwitch!
    
    var switchStateSaved = false
    var switchStateFollowing = false
    var switchStateKeyword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
    }
  
  override func viewWillAppear(animated: Bool) {
    // The avatar, name may chang during edit profile, when go back, need to reload
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
    //MARK:Get State of Switches: Saved, Following, Keyword
    @IBAction func onChangeSwitchSaved(sender: AnyObject) {
        
        if self.switchStateSaved == true  {
            self.switchStateSaved = false
        } else {
             self.switchStateSaved  = true
        }
        self.switchCellSaved.on = self.switchStateSaved
        print("Switch saved da duoc nhan", self.switchStateSaved)
    }
    
    
    @IBAction func onChangeSwitchFollowing(sender: AnyObject) {
        if self.switchStateFollowing == true  {
            self.switchStateFollowing = false
        } else {
            self.switchStateFollowing  = true
        }
        self.switchCellFollowing.on = self.switchStateFollowing
        print("Switch Following  da duoc nhan", self.switchStateFollowing)

    }
    
    @IBAction func onChangeSwitchKeyword(sender: AnyObject) {
        if self.switchStateKeyword == true  {
            self.switchStateKeyword = false
        } else {
            self.switchStateKeyword  = true
        }
        self.switchCellKeyword.on = self.switchStateKeyword
        print("Switch Keyword  da duoc nhan", self.switchStateKeyword)
        

    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.logOut()
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardID.main)
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
