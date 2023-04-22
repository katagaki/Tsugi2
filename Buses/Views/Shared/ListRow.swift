//
//  ListRow.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import SwiftUI

struct ListRow: View {
    var image: String
    var title: String
    var subtitle: String?
    var includeSpacer: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            Image(image)
                .resizable()
                .frame(width: 30.0, height: 30.0)
            VStack(alignment: .leading, spacing: 2.0) {
                Text(localized(title))
                    .font(.body)
                if let subtitle = subtitle {
                    Text(localized(subtitle))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            if includeSpacer {
                Spacer()
            }
        }
    }
}
