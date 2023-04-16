//
//  ListAppIconRow.swift
//  Buses
//
//  Created by 堅書 on 10/4/23.
//

import SwiftUI

struct ListAppIconRow: View {
    var image: String
    var text: String
    var iconToSet: String?

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            Image(image)
                .resizable()
                .frame(width: 60.0, height: 60.0)
                .clipped(antialiased: true)
                .mask {
                    RoundedRectangle(cornerRadius: 14.0)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14.0)
                        .stroke(.thickMaterial, lineWidth: 1.0)
                }
            Text(localized(text))
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.setAlternateIconName(iconToSet)
        }
    }
}
