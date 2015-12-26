//
//  ChangePasswordViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/25/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import Parse

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var retypeNewPassword: UITextField!
    
    //avatar
    @IBOutlet weak var imagePickerView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPassword.delegate = self
        newPassword.delegate = self
        retypeNewPassword.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        currentPassword.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    @IBAction func updatePasswordBtn(sender: AnyObject) {
        
        User.logInWithUsernameInBackground(User.currentUser()!.username!, password: currentPassword.text!) {
            (user:PFUser?, error:NSError?) -> Void in
            
            guard error == nil else {
                print(error)
                AlertControl.show(self, title: "Error", message: "Wrong current password", handler: nil)
                return
            }
            
            if self.newPassword.text == self.retypeNewPassword.text && self.newPassword.text!.characters.count > 0 {
                if let query6 = PFUser.query(), currentUser = User.currentUser() {
                    query6.whereKey("username", equalTo: currentUser.username!)
                    query6.findObjectsInBackgroundWithBlock({ (users, error: NSError?) -> Void in
                        if let users = users as? [User] {
                            for user in users {
                                user.password = self.newPassword.text!
                                user.saveInBackgroundWithBlock ({ (succeed, error) -> Void in
                                    guard error == nil else {
                                        if let message = error?.userInfo["error"] as? String {
                                            AlertControl.show(self, title: "Error", message: message, handler: nil)
                                        }
                                        print(error)
                                        return
                                    }
                                    
                                    User.logInWithUsernameInBackground(currentUser.username!, password: user.password!) {
                                        (user:PFUser?, error:NSError?) -> Void in
                                        
                                        guard error == nil else {
                                            print(error)
                                            return
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.view.endEditing(true)
                                            self.navigationController?.popViewControllerAnimated(true)
                                        })
                                    }
                                })
                            }
                        }
                    })
                }
            } else {
                AlertControl.show(self, title: "Error", message: "Retype wrong password", handler: nil)
            }
        }
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == currentPassword {
            if let text = textField.text where text.isEmpty {
                return false
            }
            newPassword.becomeFirstResponder()
            
        }
        if textField == newPassword {
            if let text = textField.text where text.isEmpty {
                return false
            }
            retypeNewPassword.becomeFirstResponder()
            
        }
        if textField == retypeNewPassword {
            if let text = textField.text where text.isEmpty {
                return false
            }
            self.updatePasswordBtn(textField)
        }
        
        return true
    }
}