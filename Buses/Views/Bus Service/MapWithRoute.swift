//
//  MapWithRoute.swift
//  Buses
//
//  Created by 堅書 on 15/4/23.
//

import MapKit
import SwiftUI

struct MapWithRoute: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    
    @State var useLegacyOverlay: Bool
    @Binding var placemarks: [MKPlacemark]
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 1.352083, longitude: 103.819836),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        mapView.delegate = context.coordinator
        drawRoute(mapView)
        reloadAnnotations(mapView)

        return mapView
        
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        drawRoute(uiView)
        reloadAnnotations(uiView)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func drawRoute(_ mapView: MKMapView) {
        if placemarks.count != 0 {
            if useLegacyOverlay {
                var coordinates: [CLLocationCoordinate2D] = []
                for placemark in placemarks {
                    coordinates.append(placemark.coordinate)
                }
                let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
                mapView.addOverlay(polyline)
                mapView.setVisibleMapRect(polyline.boundingMapRect,
                                          edgePadding: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                                          animated: false)
            } else {
                let maximumPlacemarksSkipped: Int = placemarks.count / 20
                var currentIndex: Int = 0
                repeat {
                    let directionsRequest = MKDirections.Request()
                    directionsRequest.source =  MKMapItem(placemark: placemarks[currentIndex])
                    directionsRequest.destination = MKMapItem(placemark: placemarks[(currentIndex + maximumPlacemarksSkipped <= placemarks.count - 1 ? currentIndex + maximumPlacemarksSkipped : placemarks.count - 1)])
                    // TODO: Change to Transit whenever Apple provides the API for it
                    directionsRequest.transportType = .automobile
                    let directions = MKDirections(request: directionsRequest)
                    directions.calculate { response, error in
                        if let response = response,
                           let route = response.routes.first {
                            mapView.addOverlay(route.polyline)
                        }
                    }
                    currentIndex += maximumPlacemarksSkipped
                } while currentIndex <= placemarks.count - 1
            }
        }
    }
    
    func reloadAnnotations(_ mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        for placemark in placemarks {
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemark.coordinate
            mapView.addAnnotation(annotation)
        }
    }

    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "AccentColor")
            renderer.lineWidth = 3
            return renderer
        }
    }

}
