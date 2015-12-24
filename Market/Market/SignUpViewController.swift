//
//  SignUpViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/8/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse


class SignUpViewController: UIViewController {
    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var spinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150))
        
        //set focus to fullnameField
        // self.fullnameField.becomeFirstResponder()
        
        // Add observer to detect when the keyboard will be shown
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        
        //Declare delegate to use textFieldShouldReturn
        fullnameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        
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
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height/2
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height/2 - offset.height
            })
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height/2
    }
    
    @IBAction func signUpTap(sender: AnyObject) {
        
        //let username = self.usernameField.text
        let fullName = self.fullnameField.text!
        let password = self.passwordField.text!
        let email = self.emailField.text!
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
        if fullName.characters.count < 5 {
         
            let alertVC = UIAlertController(title: "Invalid!", message: "Fullname must be greater than 5 characters", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertVC.addAction(alertAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
        } else if password.characters.count < 1 {
            
            let alertVC = UIAlertController(title: "Invalid!", message: "Password must be greater than 1 characters", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertVC.addAction(alertAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
        } else if email.characters.count < 8 {
            
            let alertVC = UIAlertController(title: "Invalid!", message: "Please enter a valid email address", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertVC.addAction(alertAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
        } else {
            // Run a spinner to show a task in progress
            spinner.startAnimating()
            
            let newUser = User()
            newUser.fullName = fullName
            newUser.username = finalEmail
            newUser.password = password
            newUser.email = finalEmail
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                self.spinner.stopAnimating()
                if ((error) != nil) {
                
                    let alertVC = UIAlertController(title: "Error!", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alertVC.addAction(alertAction)
                    self.presentViewController(alertVC, animated: true, completion: nil)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.gotoHome()
                    })
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

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
      if textField == fullnameField {
            if let text = textField.text where text.isEmpty {
                return false
            }
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField {
            if let text = textField.text where text.isEmpty {
                return false
            }
            emailField.becomeFirstResponder()
        }

        if textField == emailField {
            if let text = textField.text where text.isEmpty {
                return false
            }
           signUpTap(textField)
        }
        
        return true
    }
}