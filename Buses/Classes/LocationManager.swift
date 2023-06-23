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

    var shared: CLLocationManager = CLLocationManager()

    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.354454, longitude: 103.946362),
                                    latitudinalMeters: 250.0,
                                    longitudinalMeters: 250.0)
    var completion: () -> Void = {
        // Empty completion handler
    }

    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        shared.delegate = self
    }

    func updateLocation(usingOnlySignificantChanges: Bool = true) {
        if usingOnlySignificantChanges {
#if !os(xrOS)
            log("Start monitoring for significant location changes.")
            shared.startMonitoringSignificantLocationChanges()
#endif
        } else {
            log("Start updating location.")
            shared.startUpdatingLocation()
        }
    }

    func isInUsableState() -> Bool {
        return shared.authorizationStatus != .notDetermined &&
        shared.authorizationStatus != .denied &&
        shared.authorizationStatus != .restricted
    }

    func requestWhenInUseAuthorization() {
        shared.requestWhenInUseAuthorization()
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
