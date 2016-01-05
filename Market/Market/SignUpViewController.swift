//
//  SignUpViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/8/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class SignUpViewController: UIViewController {
    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullnameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fullnameField.becomeFirstResponder()
    }
    
    func onSignup() {
        var fullName = self.fullnameField.text!
        let password = self.passwordField.text!
        let email = self.emailField.text!
        fullName = fullName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
        if fullName.characters.count < 2 {
            AlertControl.show(self, title: "Invalid!", message: "Full name must be greater than a character", handler: nil)
        } else if password.characters.count < 1 {
            AlertControl.show(self, title: "Invalid!", message: "Password must be greater than 1 characters", handler: nil)
        } else if !email.isEmail() {
            AlertControl.show(self, title: "Invalid!", message: "Please enter a valid email address", handler: nil)
        } else {
            
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.applyCustomTheme("Signing up...")
            let newUser = User()
            newUser.fullName = fullName
            newUser.username = email
            newUser.password = password
            newUser.email = email
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true)
                    guard error == nil else {
                        if let message = error?.userInfo["error"] as? String {
                            AlertControl.show(self, title: "Sign up error!", message: message, handler: nil)
                        }
                        return
                    }
                    self.view.endEditing(true)
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        HomeViewController.gotoHome(true)
                    })
                })
            })
        }
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
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            if let text = textField.text where text.isEmpty || !text.isEmail() {
                return false
            }
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            if let text = textField.text where text.isEmpty {
                return false
            }
            onSignup()
        }
        
        return true
    }
}