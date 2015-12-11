//
//  ProfileViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/11/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse


class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newUser = PFUser.currentUser()
        
        self.fullnameField.text = newUser?["fullname"]! as? String
        self.phoneField.text = newUser?["phone"]! as? String
        self.addressField.text = newUser?["address"] as? String
        self.emailField.text = newUser?.email
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onUpdate(sender: AnyObject) {
        let fullname = self.fullnameField.text
        let phone = self.phoneField.text
        let address = self.addressField.text
        let email = self.emailField.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
         if fullname?.characters.count < 5 {
            let alert = UIAlertView(title: "Invalid", message: "Fullname must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else if phone?.characters.count < 1 {
            let alert = UIAlertView(title: "Invalid", message: "Phone must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else if email?.characters.count < 8 {
            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid email address", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else if address?.characters.count < 1 {
            let alert = UIAlertView(title: "Invalid", message: "Address must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            //let newUser = PFUser()
            let newUser = PFUser.currentUser()!
            
            newUser["fullname"] = fullname//fullname is an added column
            newUser["phone"] = phone //phone is an added column
            newUser["address"] = address //address is an added column
            newUser.username = finalEmail
            newUser.email = finalEmail
            
            //newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
            //newUser.saveInBackgroundWithBlock ({
              //  (succeeded: Bool, error: NSError?) -> Void in
            newUser.saveInBackgroundWithBlock ({
                (succeed, error) -> Void in

               // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                } else {
                    let alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home") //as! UIViewController
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                }
            })
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
