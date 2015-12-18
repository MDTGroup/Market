
//
//  KeywordsViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import Parse

class KeywordsViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var dataKeyword = User.currentUser()?.keywords
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.dataSource = self
        self.tableview.delegate  = self
    }
    
    @IBAction func onAddTap(sender: AnyObject) {
        var loginTextField: UITextField?
        let alertController = UIAlertController(title: "Adding a new keyword", message: "Please enter a keyword to get notifications", preferredStyle: .Alert)
        
        //When button ok is pressed, then ...
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            User.currentUser()?.addKeyword((loginTextField?.text)!, callback: { (success, error: NSError?) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                self.tableview.reloadData()
            })
        })
        
        //When button cancel is presses, then…
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            loginTextField = textField
            loginTextField?.placeholder = "Enter your Keyword"
        }
       presentViewController(alertController, animated: true, completion: nil)
    }
}

extension KeywordsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentUser = User.currentUser() {
            return currentUser.keywords.count
        }
        return 0
    }
    
    //Allow swipe right to delete a row in tableview
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            User.currentUser()?.removeKeyword((User.currentUser()?.keywords[indexPath.row])!, callback: { (success, error: NSError?) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                self.tableview.reloadData()
            })
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCellWithIdentifier("KeywordsCell1", forIndexPath: indexPath) as! KeywordsTableViewCell
        cell.keywordLabel.text = User.currentUser()?.keywords[indexPath.row]
        return cell
    }
}