//
//  BULocalizedLabel.swift
//  Buses
//
//  Created by 堅書 on 2022/04/03.
//

import UIKit

class BULocalizedLabel: UILabel {

    @IBInspectable var localizedKey: String? {
        didSet {
            guard let key = localizedKey else { return }
            text = NSLocalizedString(key, comment: "")
        }
    }

}
