//
//  MainContentViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 1/2/16.
//  Copyright © 2016 MDT Group. All rights reserved.
//

import UIKit

class MainContentViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var detailText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: imageFile)
        titleLabel.text = titleText
        detailLabel.text = detailText
    }
}