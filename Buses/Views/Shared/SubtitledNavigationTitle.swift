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
                .font(.system(size: 16.0, weight: .bold))
            Text(subtitle)
                .font(.system(size: 12.0, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding([.leading, .trailing], 8.0)
    }
}
