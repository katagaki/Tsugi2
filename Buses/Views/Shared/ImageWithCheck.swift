//
//  ImageWithCheck.swift
//  Buses
//
//  Created by 堅書 on 14/4/23.
//

import SwiftUI

struct ImageWithCheck: View {
    
    @State var image: String
    @State var label: String
    @Binding var checked: Bool
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .frame(width: 64.0, height: 128.0)
                .foregroundColor(checked ? .accentColor : .secondary)
            Text(label)
                .font(.body)
                .padding(.bottom, 8.0)
                .foregroundColor(.primary)
            if checked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
    }
}
