//
//  KatsuView.swift
//  Buses
//
//  Created by 堅書 on 2023/06/09.
//

import MapKit
import SwiftUI

struct KatsuView: View {

    @Environment(NavigationManager.self) var navigationManager
    @Environment(CoordinateManager.self) var coordinateManager
    @Environment(Toaster.self) var toaster

    @Namespace var mapScope

    @State var position: MapCameraPosition = .automatic
    @State var selectedDetent: PresentationDetent = .height(450)
    @State var mapSpan: CLLocationDegrees = .greatestFiniteMagnitude

    var body: some View {
        GeometryReader { metrics in
            Map(position: $position, scope: mapScope) {
                ForEach(coordinateManager.coordinates, id: \.id) { coordinate in
                    if isRouteStop(coordinate) && mapSpan >= 0.012 {
                        // Routes pass dozens of stops, so zoomed out they are dots, and hidden further out
                        if mapSpan < 0.04 {
                            Annotation(coordinate: coordinate.clCoordinate(), anchor: .center) {
                                Button {
                                    navigationManager.push(ViewPath.busStop(coordinate.busStop))
                                } label: {
                                    RouteStopDot()
                                }
                            } label: {
                                Text(coordinate.busStop.description ?? "")
                            }
                            .annotationTitles(.hidden)
                        }
                    } else {
                        Annotation(coordinate: coordinate.clCoordinate()) {
                            Button {
                                navigationManager.push(ViewPath.busStop(coordinate.busStop))
                            } label: {
                                Image(.listIconBus)
                                    .resizable()
                                    .frame(minWidth: 20.0, maxWidth: 20.0, minHeight: 20.0, maxHeight: 20.0)
                                    .shadow(radius: 6.0)
                            }
                        } label: {
                            Text(coordinate.busStop.description ?? "")
                        }
                    }
                }
                if coordinateManager.routeCoordinates.count > 1 {
                    // The white casing keeps the route apart from roads drawn in similar colors
                    MapPolyline(coordinates: coordinateManager.routeCoordinates)
                        .stroke(.white, style: routeStrokeStyle(lineWidth: 8.0))
                        .mapOverlayLevel(level: .aboveRoads)
                    MapPolyline(coordinates: coordinateManager.routeCoordinates)
                        .stroke(Color("AccentColor"), style: routeStrokeStyle(lineWidth: 5.0))
                        .mapOverlayLevel(level: .aboveRoads)
                }
                ForEach(coordinateManager.liveBuses) { bus in
                    Annotation(bus.serviceNo, coordinate: bus.coordinate) {
                        Image(systemName: bus.symbolName)
                            .font(.system(size: 10.0, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 22.0, height: 22.0)
                            .background(bus.color, in: .circle)
                            .overlay(Circle().stroke(.white, lineWidth: 2.0))
                            .shadow(radius: 2.0)
                    }
                    .annotationTitles(.hidden)
                }
                UserAnnotation()
            }
            .overlay {
                ZStack(alignment: .top) {
                    BlurGradientView()
                        .frame(height: metrics.safeAreaInsets.top + 12.0)
                        .ignoresSafeArea(edges: .top)
                    Color.clear
                }
                .allowsHitTesting(false)
            }
            .overlay {
                ZStack(alignment: .topLeading) {
                    if toaster.isToastShowing {
                        ToastView(message: toaster.toastMessage, toastType: toaster.toastType)
                            .onTapGesture {
                                if toaster.toastType != .persistentError && toaster.toastType != .spinner {
                                    toaster.hideToast()
                                }
                            }
                    }
                    Color.clear
                }
                .padding(EdgeInsets(top: 16.0,
                                    leading: 16.0,
                                    bottom: metrics.safeAreaInsets.bottom + 65.0,
                                    trailing: 76.0))
                .animation(.snappy, value: toaster.isToastShowing)
            }
            .sheet(isPresented: .constant(true)) {
                UnifiedView()
                    .presentationDetents([.height(200), .height(450), .large], selection: $selectedDetent)
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
            }
            .safeAreaPadding(.bottom, safeAreaPadding())
            .mapScope(mapScope)
            .mapStyle(.standard(pointsOfInterest: .including([.publicTransport])))
            .mapControls {
                // System map controls use Liquid Glass and are laid out together without overlapping
                MapUserLocationButton()
                    .mapControlVisibility(.visible)
                MapCompass()
                MapScaleView()
            }
            .onOpenURL { url in
                open(url)
            }
            .onChange(of: coordinateManager.updateCameraFlag) { _, _ in
                updateCamera()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                mapSpan = context.region.span.latitudeDelta
            }
        }
    }

    func open(_ url: URL) {
        guard let deepLink = DeepLink(url: url) else { return }
        switch deepLink {
        case .busService(let serviceNo, let busStopCode, let locationName):
            navigationManager.open(.busServiceNamed(serviceNo, atLocation: locationName,
                                                    forBusStopCode: busStopCode))
            if selectedDetent == .height(200) {
                selectedDetent = .height(450)
            }
        }
        log("Opened deep link \(url.absoluteString).")
    }

    func isRouteStop(_ coordinate: Coordinate) -> Bool {
        coordinateManager.routeCoordinates.count > 1 &&
            coordinate.busStop.code != coordinateManager.highlightedBusStopCode
    }

    func routeStrokeStyle(lineWidth: CGFloat) -> StrokeStyle {
        StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
    }

    func updateCamera() {
        let points = coordinateManager.coordinates.map { $0.clCoordinate() } +
            coordinateManager.liveBuses.map(\.coordinate)
        if points.count == 1, let point = points.first {
            // Framing a single point automatically zooms in all the way, so show the surrounding streets instead
            position = .region(MKCoordinateRegion(center: point, latitudinalMeters: 500.0, longitudinalMeters: 500.0))
        } else {
            position = .automatic
        }
    }

    func safeAreaPadding() -> CGFloat {
        switch selectedDetent {
        case .height(450): return 450.0
        case .height(200): return 200.0
        default: return 0.0
        }
    }
}

private struct RouteStopDot: View {

    var body: some View {
        // Sits inside the route line like a station on a transit map
        Circle()
            .fill(.white)
            .stroke(Color("AccentColor"), lineWidth: 1.5)
            .frame(width: 7.0, height: 7.0)
            // Keeps the dot easy to tap without making it look bigger
            .frame(width: 28.0, height: 28.0)
            .contentShape(.circle)
    }

}
