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

        // Do any additional setup after loading the view.
        //Making the avatar into round shape
        self.initControls()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        // Add observer to detect when the keyboard will be shown
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        //Declare delegate to use textFieldShouldReturn
        self.currentPassword.delegate = self
        self.newPassword.delegate = self
        self.retypeNewPassword.delegate = self 
    }
    
    override func viewWillAppear(animated: Bool) {
        // The avatar, name may chang during edit profile, when go back, need to reload
        if let currentUser = User.currentUser() {
           //load avatar
            if let imageFile = currentUser.avatar {
                imageFile.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                    self.imagePickerView.image = UIImage(data: data!)
                }
            } else {
                print("User has not profile picture")
            }
        }
    }
    func initControls() {
        self.imagePickerView.layer.cornerRadius = self.imagePickerView.frame.size.width / 2
        self.imagePickerView.clipsToBounds = true
    }
    
    /*MARK: Fix bug when keyboard slides up*/
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

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @IBAction func updatePasswordBtn(sender: AnyObject) {
    
            PFUser.logInWithUsernameInBackground(PFUser.currentUser()!.username!, password: currentPassword.text!) {
                (user:PFUser?, error:NSError?) -> Void in
                
                if error == nil {
                    
                    
                    if self.newPassword.text == self.retypeNewPassword.text {
                        
                            let query6 = PFUser.query()
                            
                            query6!.whereKey("username", equalTo: PFUser.currentUser()!.username!)
                            

                             query6?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                                for object6 in objects! {
                                    let ob6: PFObject = object6 //as! PFObject
                                    ob6["password"] = self.newPassword.text
                                    //ob6.save()
                               
                                    ob6.saveInBackgroundWithBlock ({
                                        (succeed, error) -> Void in
                                    
                                        if ((error) != nil) {
                                        
                                            let alertVC = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                                            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                                            alertVC.addAction(alertAction)
                                            self.presentViewController(alertVC, animated: true, completion: nil)
                                            
                                        
                                        } else {
                                        
                                            let alertVC = UIAlertController(title: "Success", message: "Update password", preferredStyle: UIAlertControllerStyle.Alert)
                                            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                                            alertVC.addAction(alertAction)
                                            self.presentViewController(alertVC, animated: true, completion: nil)
                                            
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                self.navigationController?.popViewControllerAnimated(true)
                                            })
                                        
                                        }
                                        print("successfully updated password")
                                    })
                                
                                }//of for
                             })
                    } else {
                        print("passwords dont match")
                        
                        let alertVC = UIAlertController(title: "Error", message: "Retype wrong password", preferredStyle: UIAlertControllerStyle.Alert)
                        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        alertVC.addAction(alertAction)
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    }
                } else {
                    
                    print("wrong current password")
                    
                    let alertVC = UIAlertController(title: "Error", message: "wrong current password", preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alertVC.addAction(alertAction)
                    self.presentViewController(alertVC, animated: true, completion: nil)

                }
                
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
