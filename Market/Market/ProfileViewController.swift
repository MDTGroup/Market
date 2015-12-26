//
//  ProfileViewController.swift
//  MarketDemo
//
//  Created by Dinh Thi Minh on 12/11/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class ProfileViewController: UIViewController {
    
    //Upload avatar
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    //User profile
    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load data
        if let currentUser = User.currentUser() {
            //load avatar
            if let imageFile = User.currentUser()!.objectForKey("avatar") as? PFFile {
                imageFile.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                    self.imagePickerView.image = UIImage(data: data!)
                }
            }
            
            //load other information
            self.fullnameField.text = currentUser.fullName
            self.phoneField.text = currentUser.phone
            self.addressField.text = currentUser.address
            self.emailField.text = currentUser.email
        }
        
        //Declare delegate to use textFieldShouldReturn
        fullnameField.delegate = self
        phoneField.delegate = self
        addressField.delegate = self
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imagePickerView.layer.cornerRadius = self.imagePickerView.frame.size.width / 2
        imagePickerView.clipsToBounds = true
    }
    
    @IBAction func onDone(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLogOut(sender: AnyObject) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Logging out..."
        User.logOutInBackgroundWithBlock({ (error) -> Void in
            guard error == nil else {
                print(error)
                if error?.code == PFErrorCode.ErrorInvalidSessionToken.rawValue {
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        ViewController.gotoMain()
                    })
                    return
                }
                return
            }
            hud.hide(true)
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                ViewController.gotoMain()
            })
        })
    }
    
    func onUpdate() {
        let fullName = self.fullnameField.text!
        let phone = self.phoneField.text!
        let address = self.addressField.text!
        let email = self.emailField.text!
        
        // Validate the text fields
        if fullName.characters.count < 2 {
            AlertControl.show(self, title: "Invalid!", message: "Full name must be greater than a character", handler: nil)
        } else if email.characters.count < 1 && email.isEmail() == false {
            AlertControl.show(self, title: "Invalid!", message: "Please enter a valid email address", handler: nil)
        } else {
            if let currentUser = User.currentUser() {
                let image = imagePickerView.image
                let thumbnails = Helper.resizeImage(image!, newWidth: 150)
                let imageFile = PFFile(data: UIImageJPEGRepresentation(thumbnails, 0.4)!)
                currentUser.avatar = imageFile
                
                //Saving othet information to currentUser
                currentUser.fullName = fullName
                currentUser.phone = phone
                currentUser.address = address
                currentUser.username = email
                currentUser.email = email
                
                //call the method to save currentUser to database
                currentUser.saveInBackgroundWithBlock ({ (succeed, error) -> Void in
                    guard error == nil else {
                        if let message = error?.userInfo["error"] as? String {
                            AlertControl.show(self, title: "Error", message: message, handler: nil)
                        }
                        print(error)
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.view.endEditing(true)
                        AlertControl.show(self, title: "Update profile", message: "Update profile successfully!", handler: nil)
                    })
                })
            }
        }
    }
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // User selected an image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = image
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // User cancel the image picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePicFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func onUpload(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tapAvatar(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}


extension ProfileViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        onUpdate()
        
        return true
    }
}
