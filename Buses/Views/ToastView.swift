//
//  ToastView.swift
//  Buses
//
//  Created by 堅書 on 16/7/22.
//

import SwiftUI

struct ToastView: View {

    var message: String
    var toastType: ToastType = .spinner

    let shape = RoundedRectangle(cornerRadius: 20.0, style: .continuous)

    var body: some View {
        HStack(alignment: .center, spacing: 10.0) {
            switch toastType {
            case .spinner:
                ProgressView()
                    .progressViewStyle(.circular)
            case .checkmark:
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            case .exclamation:
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
            case .persistentError:
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            case .none:
                Image(systemName: "ellipsis.bubble.fill")
                    .symbolRenderingMode(.monochrome)
            }
            Text(message)
                .font(.body)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0.0)
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .background {
            // A faint wash of the toast's color, so its kind can be told apart at a glance
            LinearGradient(colors: [toastType.tint.opacity(0.28), toastType.tint.opacity(0.04)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .clipShape(shape)
        }
        .glassEffect(.regular.interactive(), in: shape)
        .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
    }

}

extension ToastType {

    var tint: Color {
        switch self {
        case .persistentError: return .red
        case .exclamation: return .orange
        case .spinner, .checkmark, .none: return .blue
        }
    }

}
