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
        

    }
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        print("The keyboard is dismissed")
        
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
        print("Keyboard will show and new position y of View",self.view.frame.origin.y)
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height/2
        print("Keyboard will hide")
        
    }

    
    @IBAction func signUpTap(sender: AnyObject) {
        
        //let username = self.usernameField.text
        let fullName = self.fullnameField.text!
        let password = self.passwordField.text!
        let email = self.emailField.text!
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
        if fullName.characters.count < 5 {
//            let alert = UIAlertView(title: "Invalid", message: "Fullname must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
        } else if password.characters.count < 1 {
        //} else if count(password) < 8 {
//            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
        } else if email.characters.count < 8 {
        //} else if count(email) < 8 {
//            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid email address", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
            
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
//                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.gotoHome()
                    })
                }
            })
        }
    }
    
    func gotoHome() {
        performSegueWithIdentifier("homeSegue", sender: self)
    }
    
    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
