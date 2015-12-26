//
//  VideoViewController.swift
//  Market
//
//  Created by Dave Vo on 12/26/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController: UIViewController {
    
    var videoUrl: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let player = AVPlayer(URL: videoUrl)
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame
        
        player.play()
        
    }
    
}
