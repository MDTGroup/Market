//
//  FullImageViewController.swift
//  Market
//
//  Created by Dave Vo on 12/24/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var image: UIImage!
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: image)
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        //scrollView.contentOffset = CGPoint(x: 1000, y: 450)
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        view.addSubview(closeButton)
        
        scrollView.delegate = self
        
        setZoomScale()
        
        setupGestureRecognizer()
        
        //scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        scrollViewDidZoom(scrollView)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "onPanImage:")
        scrollView.addGestureRecognizer(panGesture)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
        
        //        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
        //            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        //        } else {
        //            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        //            print(scrollView.maximumZoomScale)
        //        }
    }
    
    func onPanImage(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        if sender.state == .Ended && (translation.y > 100 || translation.y < -100) {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func onClose(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FullImageViewController {
    static var instantiateViewController: FullImageViewController {
        return StoryboardInstance.home.instantiateViewControllerWithIdentifier(StoryboardID.fullImageViewController) as! FullImageViewController
    }
}