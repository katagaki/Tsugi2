//
//  CollapsedSearchBar.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import SwiftUI

extension PresentationDetent {
    /// The sheet shrunk down to just a search bar, leaving the map almost entirely visible.
    static let collapsed = PresentationDetent.height(collapsedHeight)
    static let half = PresentationDetent.height(450.0)

    static let collapsedHeight: CGFloat = 96.0
}

/// A search field shown in the collapsed sheet, which opens search when tapped.
struct CollapsedSearchBar: View {

    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8.0) {
                Image(systemName: "magnifyingglass")
                    .font(.body.weight(.medium))
                Text("Shared.Search")
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16.0)
            .frame(maxWidth: .infinity, minHeight: 48.0)
            .background(.fill.tertiary, in: .capsule)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16.0)
        // Leaves room for the drag indicator above
        .padding(.top, 8.0)
        .frame(maxHeight: .infinity)
    }

}
