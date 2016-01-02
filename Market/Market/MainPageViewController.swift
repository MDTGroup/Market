//
//  MainPageViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 1/2/16.
//  Copyright © 2016 MDT Group. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageTitles: [String]!
    var pageImages: [String]!
    var pageDetails: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        
        self.pageTitles = ["Notifications", "Messages", "Rich post content"]
        self.pageDetails = ["Receive notifications for post changes, new post from following, keywords and messages.", "Organize your selling/buying post messages. With messages, you can keep in touch with your customer/seller.", "You can add up to 3 images/videos in a post. With video, you can easily show your product for customers."]
        self.pageImages = ["page1", "page2", "page3"]
        
        let startVC = self.viewControllerAtIndex(0)
        
        self.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
    }
    
    func initControls() {
        view.layer.masksToBounds = true
        
        self.dataSource = self
        self.delegate = self
        
        UIPageControl.appearance().currentPageIndicatorTintColor = MyColors.green
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGrayColor()
    }
    
    func viewControllerAtIndex(index: Int) -> MainContentViewController {
        if pageTitles.count == 0 || index >= pageTitles.count {
            return MainContentViewController()
        }
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MainContentViewController") as! MainContentViewController
        
        vc.imageFile = pageImages[index]
        vc.titleText = pageTitles[index]
        vc.detailText = pageDetails[index]
        vc.pageIndex = index
        
        return vc
    }
    
    //MARK: - Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! MainContentViewController
        var index = vc.pageIndex
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index = index - 1
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! MainContentViewController
        var index = vc.pageIndex
        
        
        if (index == NSNotFound) {
            return nil
        }
        
        //index ++
        index = index + 1
        
        if (index == pageTitles.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        if self.pageTitles == nil {
            return 0
        }
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}