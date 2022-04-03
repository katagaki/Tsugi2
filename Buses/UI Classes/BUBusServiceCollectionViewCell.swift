//
//  BUBusServiceCollectionViewCell.swift
//  Buses
//
//  Created by 堅書 on 2022/04/03.
//

import UIKit

class BUBusServiceCollectionViewCell: BUCollectionViewCell {
    
    @IBOutlet weak var serviceNameLabelBackgroundView: UIView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var arrivalTime1Label: UILabel!
    @IBOutlet weak var arrivalTime2Label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        serviceNameLabelBackgroundView.layer.cornerRadius = 7.0
    }
    
}
