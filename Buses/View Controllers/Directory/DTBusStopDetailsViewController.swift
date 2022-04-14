//
//  DTBusStopDetailsViewController.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import UIKit

class DTBusStopDetailsViewController: UICollectionViewController {
    
    var busStop: BusStop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let busStop = busStop {
            // self.navigationItem.title = busStop.description
            let label = UILabel()
            label.backgroundColor = .clear
            label.numberOfLines = 2
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = .center
            label.textColor = .label
            label.text = busStop.description ?? ""
            self.navigationItem.titleView = label
        }
        
    }
    
}
