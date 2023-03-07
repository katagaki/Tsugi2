//
//  ProgressBarView.swift
//  Buses 2
//
//  Created by 堅書 on 27/2/23.
//

import SwiftUI

// Thanks to Simple Swift Guide for this amazing progress bar view
// https://www.simpleswiftguide.com/how-to-build-linear-progress-bar-in-swiftui/
struct ProgressBarView: View {
    @State var value: Float = 0.0
    @State var total: Float = 1.0
    
    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: metrics.size.width , height: metrics.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color("AccentColor"))
                Rectangle().frame(width: min(CGFloat(value / total) * metrics.size.width, metrics.size.width),
                                  height: metrics.size.height)
                .foregroundColor(Color("AccentColor"))
                .animation(.linear, value: value / total)
            }
            .cornerRadius(100.0)
        }
    }
}
