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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
