//
//  SubtitledNavigationTitle.swift
//  Buses
//
//  Created by 堅書 on 16/4/23.
//

import SwiftUI

struct SubtitledNavigationTitle: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack {
            Text(title)
                .font(Font.custom("LTA-Identity", size: 16.0))
            Text(subtitle)
                .font(Font.custom("LTA-Identity", size: 12.0))
                .foregroundColor(.secondary)
        }
        .padding([.leading, .trailing], 8.0)
    }
}
