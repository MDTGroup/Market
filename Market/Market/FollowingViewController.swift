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
    @IBOutlet weak var tableview: UITableView!
    
    
   
    let data = ["Minh Dinh","Vo Anh Dung", "Ngo Anh Tai"]
    var queryArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.dataSource = self
        self.tableview.delegate  = self
        
        
        self.loadData()
      
    }
    func loadData() {
        User.currentUser()?.getFollowings({ (users, error) -> Void in
            if error == nil {
                print("Getting the users who following current user successfully")
                //self.queryArray = users!
                for var user in users! {
                //for var user in self.queryArray {
                    print("Information of following users: ")
                    print("Username =", user.fullName)
                    print("Email = ", user.email!)
                    self.queryArray.append(user)
                    self.tableview.reloadData()
                    
                }
            } else {
                print("Current user has not had anyone following", error)
            }
        })

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
extension FollowingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return data.count
        print("Number of Rows in section = ", queryArray.count)
        return queryArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       let cell = tableview.dequeueReusableCellWithIdentifier("FollowingCell", forIndexPath: indexPath) as! FollowingTableViewCell
       
//        let cityState = data[indexPath.row].componentsSeparatedByString(", ")
//        cell.fullnameLabel.text = cityState.first
       
 
        let fullname = self.queryArray[indexPath.row].fullName
        //cell.fullnameLabel.text = "Minh"
        cell.fullnameLabel.text = fullname
        print("Fullname = ", fullname)
        
        //load avatar
        if let imgFile1 = self.queryArray[indexPath.row].objectForKey("avatar") as? PFFile {
            imgFile1.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                cell.imgField.image = UIImage(data: data!)
            }
        } else {
            print("User has not profile picture")
        }
        
        //Get target user in indexPath.row
        cell.targetUser1 = self.queryArray[indexPath.row]

     
        return cell //Tra ve cell hien hanh cua tableview
    }
}
