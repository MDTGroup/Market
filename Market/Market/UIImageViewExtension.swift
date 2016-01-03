//
//  UIImageViewExtension.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/30/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadAndFadeInWith(urlString: String, imageViews: [UIImageView]?, duration: Double) {
        let url = NSURL(string: urlString)!
        self.alpha = 0.0
        if let imageViews = imageViews {
            for imageView in imageViews {
                imageView.alpha = 0
            }
        }
        
        self.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
            self.image = image
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.alpha = 1
                if let imageViews = imageViews {
                    for imageView in imageViews {
                        imageView.alpha = 1
                    }
                }
            })
            }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                print(error)
        })
    }
    
    func noAvatar() {
        self.image = UIImage(named: "profile_blank")
    }
    
    func loadThumbnailThenOriginal(thumbnailURL: String, originalURL: String) {
        self.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: thumbnailURL)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
            self.image = image
            self.setImageWithURL(NSURL(string: originalURL)!)
            }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                print(error)
        })
    }
}