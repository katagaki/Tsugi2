//
//  ListHintOverlay.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import SwiftUI

struct ListHintOverlay: View {
    var image: String
    var text: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Image(systemName: image)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 32.0, weight: .regular))
                .foregroundColor(.secondary)
            Text(localized(text))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16.0)
    }
}
