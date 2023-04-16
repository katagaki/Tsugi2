//
//  LocationManager.swift
//  Buses
//
//  Created by 堅書 on 11/4/23.
//

import CoreLocation
import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var shouldUpdateLocationAsSoonAsPossible: Bool = false

    var locationManager: CLLocationManager = CLLocationManager()

    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.354454, longitude: 103.946362),
                                    latitudinalMeters: 250.0,
                                    longitudinalMeters: 250.0)
    var completion: () -> Void = {}

    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func updateLocation(usingOnlySignificantChanges: Bool = true) {
        if usingOnlySignificantChanges {
            log("Start monitoring for significant location changes.")
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            log("Start updating location.")
            locationManager.startUpdatingLocation()
        }
    }

    func isInUsableState() -> Bool {
        return locationManager.authorizationStatus != .notDetermined &&
        locationManager.authorizationStatus != .denied &&
        locationManager.authorizationStatus != .restricted
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

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
