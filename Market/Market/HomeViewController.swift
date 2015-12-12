//
//  HomeViewController.swift
//  Market
//
//  Created by Dave Vo on 12/3/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//
// #139EEC

import UIKit

class HomeViewController: UIViewController {
  
  
  @IBOutlet weak var tableView: UITableView!
  
  //var items = [Item]()
  var posts = [Post]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    tableView.dataSource = self
    tableView.delegate = self
    loadData()
    //loadDummyData()
    //tableView.reloadData()
  }
  
//  func loadDummyData() {
//    // Dummy data
//    
//    let thumbnails = ["http://icons.iconarchive.com/icons/pierocksmysocks/blackberry/128/BlackBerry-8707g-icon.png",
//      "http://icons.iconarchive.com/icons/pierocksmysocks/blackberry/128/BlackBerry-8700r-icon.png",
//      "http://icons.iconarchive.com/icons/pierocksmysocks/blackberry/128/BlackBerry-7520-icon.png"]
//    
//    let imageUrls = ["http://i98.photobucket.com/albums/l270/anh_dungvo/ATmega328/IMG_0086.jpg",
//      "http://i98.photobucket.com/albums/l270/anh_dungvo/ATmega328/IMG_0082.jpg",
//      "http://i98.photobucket.com/albums/l270/anh_dungvo/ATmega328/IMG_0083.jpg"]
//    
//    let avatars = ["http://icons.iconarchive.com/icons/aha-soft/free-large-boss/128/Manager-icon.png",
//      "http://icons.iconarchive.com/icons/aha-soft/free-large-boss/128/Professor-icon.png",
//      "http://icons.iconarchive.com/icons/aha-soft/free-large-boss/128/Superman-icon.png"]
//    
//    let desc = "With the iPhone 6S Apple delivered its best handset yet, but aside from sporting some fancy new 3D Touch technology it was also very similar to the iPhone 6."
//    
//    let sellers = ["Dave Vo", "Minh Dinh", "Tai Ngo"]
//    
//    items = []
//    var dict = [String: AnyObject]()
//    for index in 1...3 {
//      dict["seller"] = sellers[index-1]
//      dict["avatarURL"] = avatars[index-1]
//      dict["title"] = "Item for sell with very long name \(index)"
//      dict["description"] = desc + desc + desc
//      dict["thumbnailURL"] = thumbnails[index-1]
//      dict["itemImageURLs"] = imageUrls
//      dict["isNew"] = true
//      dict["price"] = "\(index * 3) tr"
//      dict["postedAt"] = NSDate().dayBefore(index)
//      
//      items.append(Item(dict: dict))
//    }
//  }
  
  func loadData() {
    var params = [String : AnyObject]()
    params["lastUpdatedAt"] = nil

    Post.getNewsfeed(NewsfeedType.Newest, params: params) { (posts, error) -> Void in
      if let posts = posts {
        self.posts = posts
        //print(posts)
        self.tableView.reloadData()
      } else {
        print(error)
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "detailSegue") {
      let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
      let data = sender as! Post
      detailVC.item = data
    }
  }
  
}

extension NSDate {
  func dayBefore(nDays: Int) -> NSDate {
    let oneDay:Double = 60 * 60 * 24
    return self.dateByAddingTimeInterval(-oneDay * Double(nDays))
  }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, ItemCellDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(posts.count)
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! ItemCell
    cell.item = posts[indexPath.row]
    cell.delegate = self
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Perform segue
    let item = posts[indexPath.row]
    
    performSegueWithIdentifier("detailSegue", sender: item)
  }
}
