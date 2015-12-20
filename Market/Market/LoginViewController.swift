//
//  LoginViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/8/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse


class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var spinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150))
        
        //set focus to usernameField
        //self.usernameField.becomeFirstResponder()
        
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }

    
    @IBAction func onLoginTap(sender: AnyObject) {
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        
        // Validate the text fields
        //if count(username) < 5 {
        if username.characters.count < 5 {
//            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
            
        //} else if count(password) < 8 {
        } else if password.characters.count < 1 {
//            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
            
        } else {
            // Run a spinner to show a task in progress
            
            spinner.startAnimating()
            
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
                
                // Stop the spinner
                self.spinner.stopAnimating()
                
                if  user != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print("login successfully")
                      self.gotoHome()
                    })
                    
                } else {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
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