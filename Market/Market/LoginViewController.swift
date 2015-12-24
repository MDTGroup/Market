//
//  LoginViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/8/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var origin: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        origin = view.frame.origin
        usernameField.returnKeyType = UIReturnKeyType.Next
        passwordField.returnKeyType = UIReturnKeyType.Go
        
        //set focus to usernameField
        //self.usernameField.becomeFirstResponder()
        
        
        // Add observer to detect when the keyboard will be shown
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        //Declare delegate to use textFieldShouldReturn
        self.usernameField.delegate = self
        self.passwordField.delegate = self
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    /*MARK: Fix bug when keyboard slides up*/
    //Remove observers before you leave the view  to prevent unnecessary messages from being transmitted.
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        
        if keyboardSize.height == offset.height {
            if view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y = self.origin.y - keyboardSize.height/2
                    
                })
            }
            
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y = self.origin.y + keyboardSize.height/2 - offset.height
                
            })
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = origin.y
    }
    
    @IBAction func onLoginTap(sender: AnyObject) {
        
        view.endEditing(true)
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        // Validate the text fields
        if username.characters.count == 0 || password.characters.count == 0 {
            return
        } else {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.labelText = "Logging in..."
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
                hud.hide(true)
                if  user != nil {
                    self.gotoHome()
                } else {
                    
                    let alertVC = UIAlertController(title: "Login error!", message: "Login failed! Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alertVC.addAction(alertAction)
                    self.presentViewController(alertVC, animated: true, completion: nil)
                }
            })
        }
    }
    
    func gotoHome() {
        view.endEditing(true)
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.home)
        UIApplication.sharedApplication().delegate!.window!!.rootViewController = vc
    }
    
    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            if let text = textField.text where text.isEmpty {
                return false
            }
            passwordField.becomeFirstResponder()
            
        }
        if textField == passwordField {
            if let text = textField.text where text.isEmpty {
                return false
            }
            onLoginTap(textField)
        }
        
        return true
    }
}