//
//  LocationDelegate.swift
//  Buses
//
//  Created by 堅書 on 11/4/23.
//

import CoreLocation
import Foundation
import MapKit

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {

    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.354454, longitude: 103.946362),
                                    latitudinalMeters: 250.0,
                                    longitudinalMeters: 250.0)
    var completion: () -> Void = {}
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        region.center.latitude = (manager.location?.coordinate.latitude)!
        region.center.longitude = (manager.location?.coordinate.longitude)!
        log("Updated location.")
        manager.stopUpdatingLocation()
        log("Calling completion handler in location delegate.")
        completion()
    }
    
}
