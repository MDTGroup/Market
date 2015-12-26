//
//  ResetPasswordViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/8/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        emailField.becomeFirstResponder()
    }
    
    func resetPassword() {
        if let email = self.emailField.text {
            
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.labelText = "Sending request..."
            view.endEditing(true)
            PFUser.requestPasswordResetForEmailInBackground(email) { (success, error) -> Void in
                hud.hide(true)
                guard error == nil else {
                    if let message = error?.userInfo["error"] as? String {
                        AlertControl.show(self, title: "Reset password", message: message, handler: nil)
                    }
                    print(error)
                    self.emailField.becomeFirstResponder()
                    return
                }
                if success {
                    let message = "An email containing information on how to reset your password has been sent to \(email)."
                    AlertControl.show(self, title: "Reset password", message: message) { (alertAction) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.view.endEditing(true)
                            self.onClose(self.emailField)
                        })
                    }
                } else {
                    self.emailField.becomeFirstResponder()
                    AlertControl.show(self, title: "Reset password", message: "Cannot reset password. Please try again!", handler: nil)
                }
            }
        }
    }
    
    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            if let text = textField.text where text.isEmpty || !text.isEmail() {
                return false
            }
            resetPassword()
        }
        
        return true
    }
}