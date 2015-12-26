//
//  Helper.swift
//  Market
//
//  Created by Dave Vo on 11/22/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Helper {
    
    static func timeSinceDateToNow(d: NSDate) -> String {
        let elapsedTime = NSDate().timeIntervalSinceDate(d)
        var timeSinceCreated = ""
        if elapsedTime < 60 {
            timeSinceCreated = String(Int(elapsedTime)) + "s"
        } else if elapsedTime < 3600 {
            timeSinceCreated = String(Int(elapsedTime / 60)) + "m"
        } else if elapsedTime < 24*3600 {
            timeSinceCreated = String(Int(elapsedTime / 60 / 60)) + "h"
        } else {
            timeSinceCreated = String(Int(elapsedTime / 60 / 60 / 24)) + "d"
        }
        return timeSinceCreated
    }
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        if image.size.width <= newWidth {
            return image
        }
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func compressVideo(inputURL: NSURL, outputURL: NSURL, handler:(session: AVAssetExportSession)-> Post)
    {
        let urlAsset = AVURLAsset(URL: inputURL, options: nil)
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality)
        
        exportSession!.outputURL = outputURL
        exportSession!.outputFileType = AVFileTypeQuickTimeMovie
        exportSession!.shouldOptimizeForNetworkUse = true
        exportSession!.exportAsynchronouslyWithCompletionHandler { () -> Void in
            handler(session: exportSession!)
        }
    }
}
