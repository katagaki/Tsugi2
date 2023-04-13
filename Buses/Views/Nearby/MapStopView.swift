//
//  MapStopView.swift
//  Buses
//
//  Created by 堅書 on 6/3/23.
//

import SwiftUI

struct MapStopView: View {
    
    @Binding var busStop: BusStop
    
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Image("ListIcon.Bus")
                .resizable()
                .frame(minWidth: 20.0, maxWidth: 20.0, minHeight: 20.0, maxHeight: 20.0)
                .shadow(radius: 6.0)
            StrokeText(text: busStop.description ?? "", width: 1.0, color: Color.init(uiColor: .systemBackground).opacity(0.5))
                .foregroundColor(.primary)
                .font(.caption)
        }
        .contentShape(Rectangle())
    }
}
