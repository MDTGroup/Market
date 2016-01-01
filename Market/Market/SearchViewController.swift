//
//  SearchViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/19/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var searchBar: UISearchBar!
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    var params = [String : AnyObject]()
    var selectedCondition = Condition.All
    
    enum Condition: Int {
        case New = 0
        case Used = 1
        case All = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initControls()
    }
    
    override func viewWillDisappear(animated: Bool) {
        searchBar.endEditing(true)
    }
    
    func initControls() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search posts"
        searchBar.delegate = self
        searchBar.tintColor = UIColor.darkGrayColor()
        navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add the activity Indicator for table footer for infinity load
        let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.center = tableFooterView.center
        loadingView.hidesWhenStopped = true
        tableFooterView.insertSubview(loadingView, atIndex: 0)
        // Initialize the noMoreResult
        noMoreResultLabel.frame = tableFooterView.frame
        noMoreResultLabel.text = "No more result"
        noMoreResultLabel.textAlignment = NSTextAlignment.Center
        noMoreResultLabel.font = UIFont(name: noMoreResultLabel.font.fontName, size: 15)
        noMoreResultLabel.textColor = UIColor.grayColor()
        noMoreResultLabel.hidden = true
        tableFooterView.insertSubview(noMoreResultLabel, atIndex: 0)
        tableView.tableFooterView = tableFooterView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? DetailViewController, cell = sender as? UITableViewCell {
            if let indexPath = tableView.indexPathForCell(cell) {
                detailVC.post = posts[indexPath.row]
            }
        }
    }
    
    @IBAction func onClickSettings(sender: AnyObject) {
        showActionsheets()
    }
    
    func showActionsheets() {
        let alertAS = UIAlertController(title: "Condition", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let allAction = UIAlertAction(title: "All", style: selectedCondition == .All ? .Destructive : .Default, handler: { (alertAction) -> Void in
            self.loadData(nil, condition: Condition.All)
        })
        alertAS.addAction(allAction)
        
        let newAction = UIAlertAction(title: "New", style: selectedCondition == .New ? .Destructive : .Default, handler: { (alertAction) -> Void in
            self.loadData(nil, condition: Condition.New)
        })
        alertAS.addAction(newAction)
        
        let usedAction = UIAlertAction(title: "Used", style: selectedCondition == .Used ? .Destructive : .Default, handler: { (alertAction) -> Void in
            self.loadData(nil, condition: Condition.Used)
        })
        alertAS.addAction(usedAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertAS.addAction(cancelAction)
        
        presentViewController(alertAS, animated: true, completion: nil)
    }
}

//Backend
extension SearchViewController {
    func loadData(lastCreatedAt: NSDate?, condition: Condition) {
        selectedCondition = condition
        if let text = searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where !text.isEmpty {
            Post.search(text, condition: condition.rawValue, lastCreatedAt: lastCreatedAt) { (posts, error) -> Void in
                guard error == nil else {
                    print(error)
                    self.isEndOfFeed = true
                    return
                }
                if let posts = posts {
                    if posts.count == 0 {
                        self.isEndOfFeed = true
                    }
                    
                    if lastCreatedAt == nil {
                        self.posts = posts
                    } else {
                        self.posts.appendContentsOf(posts)
                    }
                    self.tableView.reloadData()
                }
                self.noMoreResultLabel.text = self.posts.count == 0 ? "No result" : "No more result"
                self.noMoreResultLabel.hidden = !self.isEndOfFeed
                self.loadingView.stopAnimating()
                self.isLoadingNextPage = false
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        
        loadData(nil, condition: selectedCondition)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchTableViewCell", forIndexPath: indexPath) as! SearchTableViewCell
        cell.post = posts[indexPath.row]
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row >= posts.count - 2 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadData(posts[posts.count-1].createdAt!, condition: selectedCondition)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = DetailViewController.instantiateViewController
        vc.post = posts[indexPath.row]
        presentViewController(vc, animated: true, completion: nil)
    }
}