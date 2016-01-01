//
//  FollowingViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import Parse

class FollowingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var queryArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate  = self
        
        //Show data to tableview
        self.loadData()
    }
    
    
    func loadData() {
        User.currentUser()?.getFollowings({ (users, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if let users = users {
                self.queryArray = users
                self.tableView.reloadData()
            }
        })
    }
}

extension FollowingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell", forIndexPath: indexPath) as! FollowingTableViewCell
 
        let fullname = self.queryArray[indexPath.row].fullName
        cell.fullnameLabel.text = fullname
        cell.activityIndicator.hidden = true
        if let avatarFile = self.queryArray[indexPath.row].avatar {
            avatarFile.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                cell.imgField.image = UIImage(data: data!)
            }
        } else {
            print("User has not profile picture")
        }
        
        cell.targetUser = self.queryArray[indexPath.row]

        return cell
    }
}