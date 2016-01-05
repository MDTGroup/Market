//
//  SettingsTableViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/11/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var imagePickerView: UIImageView!
    
    //SWITCH BUTTONS
    @IBOutlet weak var switchCellSaved: UISwitch!
    @IBOutlet weak var switchCellFollowing: UISwitch!
    @IBOutlet weak var switchCellKeyword: UISwitch!
    
    var switchStateSaved = true
    var switchStateFollowing = true
    var switchStateKeyword = true
    
    //Change pwd
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
        
        //set state for swicher from Cloud
        var needToSaveToCloud = false
        let installation = PFInstallation.currentInstallation()
        var enableNotificationForSavedPosts = installation.valueForKey("enableNotificationForSavedPosts") as? Bool
        if enableNotificationForSavedPosts == nil {
            enableNotificationForSavedPosts = true
            needToSaveToCloud = true
        }
        switchCellSaved.on = enableNotificationForSavedPosts!
        
        var enableNotificationForFollowing = installation.valueForKey("enableNotificationForFollowing") as? Bool
        if enableNotificationForFollowing == nil {
            enableNotificationForFollowing = true
            needToSaveToCloud = true
        }
        switchCellFollowing.on = enableNotificationForFollowing!
        
        var enableNotificationForKeywords = installation.valueForKey("enableNotificationForKeywords") as? Bool
        if enableNotificationForKeywords == nil {
            enableNotificationForKeywords = true
            needToSaveToCloud = true
        }
        switchCellKeyword.on = enableNotificationForKeywords!
        
        if needToSaveToCloud {
            updateNotificationConfig()
        }
    }
    
    func updateNotificationConfig() {
        let installation = PFInstallation.currentInstallation()
        installation.setValue(switchCellSaved.on, forKey: "enableNotificationForSavedPosts")
        installation.setValue(switchCellFollowing.on, forKey: "enableNotificationForFollowing")
        installation.setValue(switchCellKeyword.on, forKey: "enableNotificationForKeywords")
        installation.saveInBackground()
    }
    
    @IBAction func onCloseSettings(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK:Get State of Switches: Saved, Following, Keyword
    @IBAction func onChangeSwitchSaved(sender: AnyObject) {
        
        updateNotificationConfig()
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.applyCustomTheme("Logging out...")
        
        let installation = PFInstallation.currentInstallation()
        installation["loggedOut"] = true
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            
            guard error == nil else {
                print(error)
                hud.hide(true)
                return
            }
            
            User.logOutInBackgroundWithBlock({ (error) -> Void in
                hud.hide(true)
                
                guard error == nil else {
                    print(error)
                    return
                }
                
                ViewController.gotoMain(true)
                
                
            })
        }
    }
    
    @IBAction func onChangePwd(sender: AnyObject) {
        let titlePrompt = UIAlertController(title: "Reset password",
            message: "Enter the email you registered with:",
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler { (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Email"
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        titlePrompt.addAction(cancelAction)
        
        titlePrompt.addAction(UIAlertAction(title: "Reset", style: .Destructive, handler: { (action) -> Void in
            if let textField = titleTextField {
                self.resetPassword(textField.text!)
            }
        }))
        
        self.presentViewController(titlePrompt, animated: true, completion: nil)
    }
    
    func resetPassword(email : String){
        
        // convert the email string to lower case
        let emailToLowerCase = email.lowercaseString
        // remove any whitespaces before and after the email address
        let emailClean = emailToLowerCase.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //put in a activity indicator, so that users see that the app is busy in between the actions
        self.pause()
        PFUser.requestPasswordResetForEmailInBackground(emailClean) { (success, error) -> Void in
            if (error == nil) {
                let success = UIAlertController(title: "Success", message: "Success! Check your email!", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                success.addAction(okButton)
                self.presentViewController(success, animated: false, completion: nil)
                self.restore()
                
                
            }else {
                let errormessage = error!.userInfo["error"] as! NSString
                let error = UIAlertController(title: "Cannot complete request", message: errormessage as String, preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                error.addAction(okButton)
                self.presentViewController(error, animated: false, completion: nil)
                
                self.restore()
            }
        }
    }
    /*
    If you want to put in a activity indicator, so that users see that the app is busy in between the actions, create the following two methods and call Pause() in the Reset action and Restore() just before or after the if/else in the resetPassword method
    */
    func pause(){
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func restore(){
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
