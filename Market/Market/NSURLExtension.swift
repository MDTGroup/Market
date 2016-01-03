//
//  NSURLExtension.swift
//  Market
//
//  Created by Ngo Thanh Tai on 1/4/16.
//  Copyright © 2016 MDT Group. All rights reserved.
//

import AVFoundation
import UIKit

extension NSURL {
    func getThumbnailOfVideoURL() -> UIImage? {
        let asset = AVAsset(URL: self)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(asset.duration.value / 3, asset.duration.timescale)
        if let cgImage = try? assetImgGenerate.copyCGImageAtTime(time, actualTime: nil) {
            let image = UIImage(CGImage: cgImage)
            return image
        }
        return nil
    }
}