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
            } else {
                print("User has not profile picture")
            }
            
            //load other information
            self.fullnameField.text = currentUser.fullName
            self.phoneField.text = currentUser.phone
            self.addressField.text = currentUser.address
            self.emailField.text = currentUser.email
            
            
            
           // Add observer to detect when the keyboard will be shown
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
            
           
            
            //Looks for single or multiple taps.
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
            self.view.addGestureRecognizer(tap)
            
        }
        
        //Declare delegate to use textFieldShouldReturn
        fullnameField.delegate = self
        phoneField.delegate = self
        addressField.delegate = self
   }
  
  
   //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        print("The keyboard is dismissed")
        
    }
    
    
    /*MARK: Fix bug when keyboard slides up*/
//    func keyboardWillShow(notification: NSNotification) {
//       if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//          self.view.frame.origin.y -= keyboardSize.height/2
//            
//        }
//    }
    //Remove observers before you leave the view  to prevent unnecessary messages from being transmitted.
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
   
//    func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//            self.view.frame.origin.y += keyboardSize.height/2
//            print("Keyboard will hide")
//        }
//    }
    


    //Making the avatar into round shape
    override func viewWillAppear(animated: Bool) {
        //Set imagePickerView from square to round shape
        self.imagePickerView.layer.cornerRadius = self.imagePickerView.frame.size.width / 2
        self.imagePickerView.clipsToBounds = true
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func onUpdate(sender: AnyObject) {
        let fullname = self.fullnameField.text
        let phone = self.phoneField.text
        let address = self.addressField.text
        let email = self.emailField.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
//        if fullname?.characters.count < 5 {
//            let alert = UIAlertView(title: "Invalid", message: "Fullname must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
//        } else if phone?.characters.count < 1 {
//            let alert = UIAlertView(title: "Invalid", message: "Phone must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
//        } else if email?.characters.count < 8 {
//            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid email address", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
//        } else if address?.characters.count < 1 {
//            let alert = UIAlertView(title: "Invalid", message: "Address must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
//        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            if let currentUser = User.currentUser() {
                //get the data from photos and save it to currentUser
                let image = imagePickerView.image
                let thumbnails = resizeImage(image!, newWidth: 150)
                //let imageFile = PFFile(name: "img1.png", data: UIImagePNGRepresentation(image!)!)!
                //let imageFile = PFFile(data: UIImagePNGRepresentation(image!)!)
                //let imageFile = PFFile(data: UIImagePNGRepresentation(thumbnails)!)
                let imageFile = PFFile(data: UIImageJPEGRepresentation(thumbnails, 0.4)!)
                currentUser.avatar = imageFile
                
                
                //Saving othet information to currentUser
                currentUser.fullName = fullname!
                currentUser.phone = phone
                currentUser.address = address
                currentUser.username = finalEmail
                currentUser.email = finalEmail
            
            
            
                //call the method to save currentUser to database
                currentUser.saveInBackgroundWithBlock ({
                (succeed, error) -> Void in

               // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
//                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                    
                } else {
//                    let alert = UIAlertView(title: "Success", message: "Update profile", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    
                }
            })
            }
//        }

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
        fullnameField.returnKeyType = UIReturnKeyType.Next
        phoneField.returnKeyType = UIReturnKeyType.Next
        addressField.returnKeyType = UIReturnKeyType.Next
        
        
        if textField == fullnameField {
            phoneField.becomeFirstResponder()
        }
        if textField == phoneField {
            addressField.becomeFirstResponder()
        }
        if textField == addressField {
            fullnameField.becomeFirstResponder()
        }
        
        return true
    }
}
