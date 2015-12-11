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
                
                if ((user) != nil) {
//                    let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home") //as! UIViewController
//                        self.presentViewController(viewController, animated: true, completion: nil)
                        print("login successfully")
                    })
                    
                } else {
//                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                }
            })
        }
    }
   
    
    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}