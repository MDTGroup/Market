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
        navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? DetailViewController, cell = sender as? UITableViewCell {
            if let indexPath = tableView.indexPathForCell(cell) {
                detailVC.post = posts[indexPath.row]
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var params = [String : AnyObject]()
        params["lastUpdatedAt"] = nil
        params["text"] = searchBar.text
        Post.search(params) { (posts, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if let posts = posts {
                self.posts = posts
                self.tableView.reloadData()
            }
        }
        
        searchBar.endEditing(true)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchTableViewCell", forIndexPath: indexPath) as! SearchTableViewCell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = DetailViewController.instantiateViewController
        vc.post = posts[indexPath.row]
        presentViewController(vc, animated: true, completion: nil)
    }
}