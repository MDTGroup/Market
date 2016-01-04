//
//  JSQCustomVideoMediaItem.swift
//  Market
//
//  Created by Ngo Thanh Tai on 1/4/16.
//  Copyright © 2016 MDT Group. All rights reserved.
//

import Foundation
import JSQMessagesViewController
class JSQCustomVideoMediaItem: JSQVideoMediaItem {
    var cachedVideoImageView: UIImageView?
    var thumbnailURL: String?
    override func mediaView() -> UIView! {
        if self.fileURL == nil || !self.isReadyToPlay {
            return nil
        }
        if cachedVideoImageView == nil {
            let size = self.mediaViewDisplaySize()
            if let thumbnailURL = thumbnailURL {
                cachedVideoImageView = UIImageView()
                cachedVideoImageView?.setImageWithURL(NSURL(string: thumbnailURL)!)
            } else {
                if let image = self.fileURL.getThumbnailOfVideoURL() {
                    cachedVideoImageView = UIImageView(image: image)
                }
            }
            if let cachedVideoImageView = cachedVideoImageView {
                cachedVideoImageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
                cachedVideoImageView.contentMode = .ScaleAspectFill
                cachedVideoImageView.clipsToBounds = true
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(cachedVideoImageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
                
                let playImage = UIImage(named: "play")
                let playImageView = UIImageView(image: playImage)
                playImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                playImageView.center = cachedVideoImageView.center
                cachedVideoImageView.addSubview(playImageView)
            }
            return cachedVideoImageView
        }
        return super.mediaView()
    }
}