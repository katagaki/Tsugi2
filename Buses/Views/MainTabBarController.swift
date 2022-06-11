//
//  MainTabBarController.swift
//  Buses
//
//  Created by 堅書 on 2022/04/03.
//

import CoreLocation
import UIKit
import SwiftUI

class MainTabBarController: UITabBarController,
                            CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch locationManager.authorizationStatus {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted: break // TODO: Show popup to continue or go to Settings
        default: break // All good
        }
    }
    
}
