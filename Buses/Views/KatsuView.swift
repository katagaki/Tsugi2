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

    var body: some View {
        GeometryReader { metrics in
            Map(position: $position, scope: mapScope) {
                ForEach(coordinateManager.coordinates, id: \.id) { coordinate in
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
                if coordinateManager.routeCoordinates.count > 1 {
                    MapPolyline(coordinates: coordinateManager.routeCoordinates)
                    .stroke(Color.init(uiColor: UIColor(named: "AccentColor")!),
                            lineWidth: 5.0)
                    .mapOverlayLevel(level: .aboveRoads)
                }
                ForEach(coordinateManager.liveBuses) { bus in
                    Annotation(bus.serviceNo, coordinate: bus.coordinate) {
                        Image(systemName: bus.symbolName)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(6.0)
                            .background(bus.color, in: .circle)
                            .overlay(Circle().stroke(.white, lineWidth: 2.0))
                            .shadow(radius: 3.0)
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
            .onChange(of: coordinateManager.updateCameraFlag) { _, _ in
                updateCamera()
            }
        }
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
