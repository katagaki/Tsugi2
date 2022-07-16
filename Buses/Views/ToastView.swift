//
//  ToastView.swift
//  Buses
//
//  Created by 堅書 on 16/7/22.
//

import SwiftUI

struct ToastView: View {
    
    var message: String
    var showsProgressView: Bool = false
    var showsCheckmark: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            if showsProgressView {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            if showsCheckmark {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            }
            Text(message)
                .font(.body)
        }
        .padding(EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
        .background(Color(uiColor: .systemBackground))
        .mask {
            RoundedRectangle(cornerRadius: 8.0)
        }
        .shadow(radius: 2.5)
        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
    }
}
