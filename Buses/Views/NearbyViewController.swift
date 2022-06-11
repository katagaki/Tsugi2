//
//  NearbyViewController.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import MapKit
import UIKit

class NearbyViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.userTrackingMode = .follow
    }
}
