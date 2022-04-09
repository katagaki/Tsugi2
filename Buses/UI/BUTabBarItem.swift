//
//  BUTabBarItem.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import UIKit

class BUTabBarItem: UITabBarItem {
    
    @IBInspectable var localizedKey: String? {
        didSet {
            guard let key = localizedKey else { return }
            title = NSLocalizedString(key, comment: "")
        }
    }
    
}
