//
//  MainTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct MainTabView: View {
    
    @State var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.30437, longitude: 103.82458), latitudinalMeters: 50000.0, longitudinalMeters: 50000.0)
    @State var userTrackingMode: MapUserTrackingMode = .follow
    
    var body: some View {
        
        GeometryReader { metrics in
            ZStack(alignment: .bottomLeading) {
                Map(coordinateRegion: $coordinateRegion,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode)
                .edgesIgnoringSafeArea(.all)
                TabView {
                    NearbyView()
                        .tabItem {
                            Label("TabTitle.Nearby", systemImage: "map.fill")
                        }
                    FavoritesView()
                        .tabItem {
                            Label("TabTitle.Favorites", systemImage: "star.fill")
                        }
                    DirectoryView()
                        .tabItem {
                            Label("TabTitle.Directory", systemImage: "book.closed.fill")
                        }
                    MoreView()
                        .tabItem {
                            Label("TabTitle.More", systemImage: "ellipsis")
                        }
                }
                .mask {
                    RoundedCornersShape(corners: [.topLeft, .topRight], radius: 12.0)
                }
                .edgesIgnoringSafeArea(.all)
                .shadow(radius: 5.0)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: metrics.size.height * 0.55)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

struct RoundedCornersShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
