//
//  KeywordsTableViewCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

@objc protocol KeywordsTableViewCellDelegate {
    optional func keywordsTableViewCell(keywordsTableViewCell: KeywordsTableViewCell, didDelete value: Bool)
}

class KeywordsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    weak var delegate: KeywordsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onDeleteTap(sender: AnyObject) {
        print("Button delete is clicked")
        User.currentUser()?.removeKeyword(keywordLabel.text!, callback: { (success, error: NSError?) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.delegate?.keywordsTableViewCell!(self, didDelete: true)
        })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
