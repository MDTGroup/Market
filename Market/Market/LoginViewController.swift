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
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        emailField.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func onLogin() {
        let username = self.emailField.text!
        let password = self.passwordField.text!
        
        if username.characters.count == 0 || password.characters.count == 0 {
            return
        } else {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.applyCustomTheme("Logging in...")
            view.endEditing(true)
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true)
                    if  user != nil {
                        self.view.endEditing(true)
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            HomeViewController.gotoHome(true)
                        })
                    } else {
                        AlertControl.show(self, title: "Login error!", message: "Login failed! Please try again!", handler: { (alertVC) -> Void in
                            self.passwordField.text = ""
                            self.passwordField.becomeFirstResponder()
                        })
                    }
                })
            })
        }
    }
    
    @IBAction func onClose(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            if let text = textField.text where text.isEmpty || !text.isEmail() {
                return false
            }
            passwordField.becomeFirstResponder()
            
        }
        else if textField == passwordField {
            if let text = textField.text where text.isEmpty {
                return false
            }
            onLogin()
        }
        
        return true
    }
}