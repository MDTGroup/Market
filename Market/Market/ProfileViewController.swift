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
        
        // Do any additional setup after loading the view.
        //cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
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
        }
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
                        
                        //Return Settings screen(that has storyboard id =  "SettingsScreen") in storyboard = "Settings"
                        let viewController:UIViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsScreen") //as! UIViewController
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                    
                }
            })
            }
//        }

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
}


    
    

