//
//  ProgressBarView.swift
//  Buses 2
//
//  Created by 堅書 on 27/2/23.
//

import SwiftUI

struct ProgressBarView: View {
    @State var value: Float = 0.0
    @State var total: Float = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color("AccentColor"))
                Rectangle().frame(width: min(CGFloat(value / total) * geometry.size.width, geometry.size.width),
                                  height: geometry.size.height)
                .foregroundColor(Color("AccentColor"))
                .animation(.linear, value: value / total)
            }
            .cornerRadius(100.0)
        }
    }
}
