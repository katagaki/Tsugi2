//
//  KatsuView.swift
//  Buses
//
//  Created by 堅書 on 2023/06/09.
//

import MapKit
import Polyline
import SwiftUI

struct KatsuView: View {

    @EnvironmentObject var coordinateManager: CoordinateManager
    @EnvironmentObject var toaster: Toaster

    @Namespace var mapScope

    @State var position: MapCameraPosition = .automatic
    @State var isMoreSheetPresented: Bool = false

    var body: some View {
        GeometryReader { metrics in
            Map(position: $position, scope: mapScope) {
                ForEach(coordinateManager.coordinates, id: \.id) { coordinate in
                    Annotation(coordinate: coordinate.clCoordinate()) {
                        Image(.listIconBus)
                            .resizable()
                            .frame(minWidth: 20.0, maxWidth: 20.0, minHeight: 20.0, maxHeight: 20.0)
                            .shadow(radius: 6.0)
                    } label: {
                        Text(coordinate.busStop.description ?? "")
                    }
                }
                if let polylineString = coordinateManager.polyline,
                   let decodedCoordinates: [CLLocationCoordinate2D] = decodePolyline(polylineString) {
                    MapPolyline(MKPolyline(coordinates: decodedCoordinates,
                                           count: decodedCoordinates.count))
                    .stroke(Color.init(uiColor: UIColor(named: "AccentColor")!),
                            lineWidth: 5.0)
                    .mapOverlayLevel(level: .aboveRoads)
                }
                UserAnnotation()
            }
            .overlay {
                ZStack(alignment: .topTrailing) {
                    BlurGradientView()
                        .frame(height: metrics.safeAreaInsets.top + 12.0)
                        .ignoresSafeArea(edges: .top)
                    VStack(alignment: .trailing, spacing: 8.0) {
                        Button {
                            isMoreSheetPresented = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .frame(width: 44.0, height: 44.0)
                                .contentShape(Rectangle())
                        }
                        .background(.thickMaterial)
                        .mask {
                            RoundedRectangle(cornerRadius: 10.0)
                        }
                        .shadow(radius: 2.5)
                        MapUserLocationButton(scope: mapScope)
                            .mapControlVisibility(.visible)
                            .buttonBorderShape(.roundedRectangle)
                            .mask {
                                RoundedRectangle(cornerRadius: 10.0)
                            }
                            .shadow(radius: 2.5)
                    }
                    .padding()
                    Color.clear
                }
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
            .safeAreaInset(edge: .bottom) {
                MainTabView()
                    .frame(height: metrics.size.height * 0.6)
                    .shadow(radius: 10.0)
            }
            .mapScope(mapScope)
            .mapControls {
                MapCompass()
                    .mapControlVisibility(.hidden)
            }
            .onChange(of: coordinateManager.updateCameraFlag) { _, _ in
                position = .automatic
            }
            .sheet(isPresented: $isMoreSheetPresented, content: {
                MoreView()
                    .presentationDragIndicator(.visible)
            })
        }
    }
}
