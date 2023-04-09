//
//  ListSectionHeader.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import SwiftUI

struct ListSectionHeader: View {
    var text: String
    
    var body: some View {
        Text(localized(text))
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .textCase(nil)
    }
}