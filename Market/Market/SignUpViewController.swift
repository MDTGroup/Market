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
//                    let alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home") //as! UIViewController
                        //self.presentViewController(viewController, animated: true, completion: nil)
                        print("registered")
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
