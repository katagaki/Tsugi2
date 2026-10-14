//
//  CollapsedSearchBar.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import SwiftUI

extension PresentationDetent {
    /// The sheet shrunk down to a search bar, leaving the map almost entirely visible.
    static let collapsed = PresentationDetent.height(collapsedHeight)
    static let half = PresentationDetent.height(450.0)

    static let collapsedHeight: CGFloat = 64.0
}

/// Stands in for the sheet's contents when it is collapsed, and opens search when tapped.
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
            .padding(.horizontal, 24.0)
            // The collapsed sheet is itself the search bar, so the whole sheet can be tapped
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

}
