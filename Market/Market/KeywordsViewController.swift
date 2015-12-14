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
    
    let dataKeyword = ["IPhone","SamSung", "IPad"]

    
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
        return dataKeyword.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCellWithIdentifier("KeywordsCell1", forIndexPath: indexPath) as! KeywordsTableViewCell
        
        let keyword = dataKeyword[indexPath.row].componentsSeparatedByString(", ")
        cell.keywordLabel.text = keyword.first
        

        return cell //Tra ve cell hien hanh cua tableview
    }
}