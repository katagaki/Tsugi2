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
    @State var currentBusStopCode: String
    @Binding var busStops: [BusStop]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
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
        if busStops.count != 0 {
            if useLegacyOverlay {
                var coordinates: [CLLocationCoordinate2D] = []
                for busStop in busStops {
                    if let latitude = busStop.latitude,
                       let longitude = busStop.longitude {
                        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                                       longitude: longitude))
                        coordinates.append(placemark.coordinate)
                    }
                }
                let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
                mapView.addOverlay(polyline, level: .aboveRoads)
                mapView.setVisibleMapRect(polyline.boundingMapRect,
                                          edgePadding: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                                          animated: false)
            } else {
                let skipCount: Int = busStops.count / 25
                var currentIndex: Int = 0
                repeat {
                    let startIndex = currentIndex
                    let endIndex = (currentIndex + skipCount <= busStops.count - 1 ?
                                    currentIndex + skipCount : busStops.count - 1)
                    let directionsRequest = MKDirections.Request()
                    if let sourceLatitude = busStops[startIndex].latitude,
                       let sourceLongitude = busStops[startIndex].longitude,
                       let destinationLatitude = busStops[endIndex].latitude,
                       let destinationLongitude = busStops[endIndex].latitude {
                        directionsRequest.source =  MKMapItem(
                            placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceLatitude,
                                                                                      longitude: sourceLongitude)))
                        directionsRequest.destination = MKMapItem(
                            placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLatitude,
                                                                                      longitude: destinationLongitude)))
                        // TODO: Change to Transit whenever Apple provides the API for it
                        directionsRequest.transportType = .automobile
                        let directions = MKDirections(request: directionsRequest)
                        directions.calculate { response, _ in
                            if let response = response,
                               let route = response.routes.first {
                                mapView.addOverlay(route.polyline)
                            }
                        }
                    }
                    currentIndex += skipCount
                } while currentIndex <= busStops.count - 1
            }
        }
    }

    func reloadAnnotations(_ mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        for busStop in busStops {
            if let latitude = busStop.latitude,
               let longitude = busStop.longitude,
               let description = busStop.description {
                let annotation = MapWithRoutePointAnnotation()
                annotation.isCurrentBusStop = currentBusStopCode == busStop.code
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = description
                mapView.addAnnotation(annotation)
            }
        }
    }

    class MapWithRoutePointAnnotation: MKPointAnnotation {
        var isCurrentBusStop: Bool = false
    }

    class MapViewCoordinator: NSObject, MKMapViewDelegate {

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "AccentColor")
            renderer.lineWidth = 3
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.canShowCallout = false
            annotationView.image = UIImage(named: "ListIcon.BusStop")
            annotationView.annotation = annotation
            annotationView.bounds.size = CGSize(width: 16.0, height: 16.0)
            return annotationView
        }

    }

}
