
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
    
    //var dataKeyword = ["IPhone","SamSung", "IPad"]
    var dataKeyword = User.currentUser()?.keywords
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.dataSource = self
        self.tableview.delegate  = self
        
        tableview.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   //Add text into array data
    @IBAction func onAddTap(sender: AnyObject) {
        var loginTextField: UITextField?
        let alertController = UIAlertController(title: "Adding a new keyword", message: "Please enter a keyword to get notifications", preferredStyle: .Alert)
        
        //When button ok is pressed, then ...
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            print("Ok Button Pressed")
            //print string that you have just added
            print("\(loginTextField!.text)")
            
            //insert new string has just inputed into dataKeyword array and refresh tableview
//            self.dataKeyword.insert((loginTextField?.text)!, atIndex: 0)
//            self.tableview.reloadData()

            //User.currentUser()?.addKeyword("IPhone6s", callback: { (success, error:
            User.currentUser()?.addKeyword((loginTextField?.text)!, callback: { (success, error: NSError?) -> Void in
                if error == nil {
                    //print keyword in keywords array to console for testing
                    for var key in (User.currentUser()?.keywords)! {
                        print(key)
                    }
                    print("Adding a keyword successfully")
                    //refresh tableview
                    self.tableview.reloadData()
                } else {
                    print("Can not add a new keyword: ", error )
                }
            })
            
        })
        
        //When button cancel is presses, then…
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            // Enter the textfiled customization code here.
            loginTextField = textField
            loginTextField?.placeholder = "Enter your Keyword"
        }
       presentViewController(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension KeywordsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //return dataKeyword.count
            //return (self.dataKeyword?.count)!
            return (User.currentUser()?.keywords.count)!
    }
    
    //Allow swipe right to delete a row in tableview
  /*  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            dataKeyword.removeAtIndex(indexPath.row)
            self.tableview.reloadData()
        }
    }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCellWithIdentifier("KeywordsCell1", forIndexPath: indexPath) as! KeywordsTableViewCell
        
        //let keyword = dataKeyword[indexPath.row].componentsSeparatedByString(", ")
        //let keyword = dataKeyword[indexPath.row]
        //cell.keywordLabel.text = keyword.first
        cell.keywordLabel.text = User.currentUser()?.keywords[indexPath.row]
        
        

        return cell //Tra ve cell hien hanh cua tableview
    }
}