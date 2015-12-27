//
//  KeywordsTableViewCell.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

protocol KeywordsTableViewCellDelegate {
    func keywordsTableViewCell(keywordsTableViewCell: KeywordsTableViewCell, keyword value: String)
}

class KeywordsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    var delegate: KeywordsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onDeleteTap(sender: AnyObject) {
       self.delegate?.keywordsTableViewCell(self, keyword: keywordLabel.text!)
    }
}
