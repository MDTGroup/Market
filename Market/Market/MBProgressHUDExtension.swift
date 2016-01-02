//
//  MBProgressHUD.swift
//  Market
//
//  Created by Ngo Thanh Tai on 1/2/16.
//  Copyright © 2016 MDT Group. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD {
    func applyCustomTheme(text: String?) {
        if let text = text {
            self.labelText = text
        }
        self.labelColor = UIColor.whiteColor()
        self.activityIndicatorColor = UIColor.whiteColor()
        self.color = MyColors.navigationTintColor
        self.alpha = 0.8
    }
}