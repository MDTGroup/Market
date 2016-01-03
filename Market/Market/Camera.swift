//
//  Camera.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/28/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import MobileCoreServices

class Camera {
    
    enum MediaType: Int {
        case TakePhoto
        case Record30sVideo
        case PickPhoto
        case PickVideo
    }
    
    static func loadMediaFrom(target: AnyObject, sourceType: UIImagePickerControllerSourceType, mediaType: MediaType) {
        let imagePicker = UIImagePickerController()
        if let postVC = target as? PostViewController {
            imagePicker.delegate = postVC
        } else if let chatVC = target as? ChatViewController {
            imagePicker.delegate = chatVC
        }
        imagePicker.sourceType = sourceType
        
        switch mediaType {
        case .PickPhoto, .TakePhoto:
            imagePicker.mediaTypes = [kUTTypeImage as String]
        case .PickVideo, .Record30sVideo:
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = true
            imagePicker.videoMaximumDuration = 30
        }
        
        target.presentViewController(imagePicker, animated: true, completion: nil)
    }
}