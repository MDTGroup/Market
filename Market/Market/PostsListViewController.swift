//
//  PostsListViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/18/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD

class PostsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        // Refresh control
        refreshControl.addTarget(self, action: Selector("loadNewestData"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        // Add the activity Indicator for table footer for infinity load
        let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.center = tableFooterView.center
        loadingView.hidesWhenStopped = true
        tableFooterView.addSubview(loadingView)
        
        
        // Initialize the noMoreResult
        noMoreResultLabel.frame = tableFooterView.frame
        noMoreResultLabel.text = "No more result"
        noMoreResultLabel.textAlignment = NSTextAlignment.Center
        noMoreResultLabel.font = UIFont(name: noMoreResultLabel.font.fontName, size: 15)
        noMoreResultLabel.textColor = UIColor.grayColor()
        noMoreResultLabel.hidden = true
        tableFooterView.addSubview(noMoreResultLabel)
        tableView.tableFooterView = tableFooterView
        
        //        let postVC: PostViewController = tabBarController?.viewControllers![1] as! PostViewController
        //        postVC.delegate = self
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadNewestData()

    }
    
    func loadNewestData() {
        posts = []
        loadData(nil)
    }
    
    func loadData(lastUpdatedAt: NSDate?) {
        User.currentUser()?.getSavedPosts(lastUpdatedAt) { (posts, error) -> Void in
            if let posts = posts {
                if posts.count == 0 {
                    self.isEndOfFeed = true
                }
                
                self.posts.appendContentsOf(posts)
                self.tableView.reloadData()
                
            } else {
                print(error)
                self.isEndOfFeed = true
            }
            
            self.noMoreResultLabel.hidden = !self.isEndOfFeed
            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
            self.isLoadingNextPage = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
}
extension PostsListViewController: UITableViewDelegate, UITableViewDataSource, ItemListCellDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemListCell1", forIndexPath: indexPath) as! ItemListCell
        cell.item = posts[indexPath.row]
        cell.delegate = self
        
        // Infinite load if last cell
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row == posts.count - 1 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadData(cell.item.updatedAt!)
            }
        }
        
        return cell
    }
}
