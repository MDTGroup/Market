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
    
   // var queryArray: [PFObject] = [PFObject]()
    var queryArray: [PFUser] = [PFUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.dataSource = self
        self.tableview.delegate  = self
        
        tableview.reloadData()
        //loaddata()
    
    }
    
//    func loaddata() {
//        var query = PFQuery(className:"User")
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [AnyObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                print("Successfully retrieved \(objects!.count) Restaurantes.")
//                if let _objects = objects as? [PFObject] {
//                    self.queryArray = _objects
//                    self.tableView.reloadData()
//                }
//            } else {
//                print("Error: \(error!) \(error!.userInfo!)")
//            }
//        }
//    }

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
        return data.count//tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       let cell = tableview.dequeueReusableCellWithIdentifier("FollowingCell", forIndexPath: indexPath) as! FollowingTableViewCell
       
        let cityState = data[indexPath.row].componentsSeparatedByString(", ")
        cell.fullnameLabel.text = cityState.first
        
//        let user = queryArray[indexPath.row] as! PFUser
//
//        cell.fullnameLabel.text = user.valueForKey("fullname") //as! NSString
//        //cell.imageBg.image = UIImage(named: "www.maisturismo.jpg")
//        
       
       
        
        return cell //Tra ve cell hien hanh cua tableview 
    }
}
