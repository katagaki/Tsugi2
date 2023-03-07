//
//  BlurGradientView.swift
//  Buses
//
//  Created by 堅書 on 7/3/23.
//

import SwiftUI

// Thanks to aheze's answer for the blur upgrade, and Classroom of the Elite is great too
// https://stackoverflow.com/questions/68138347/
struct BlurGradientView: View {
    
    let gradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .black, location: 0.7),
                .init(color: .clear, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .background(.ultraThinMaterial)
            .mask(gradient)
    }
}
