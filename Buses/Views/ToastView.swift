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

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
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
            Spacer()
        }
        .padding(12.0)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .mask {
            RoundedRectangle(cornerRadius: 10.0)
        }
        .shadow(radius: 2.5)
        .overlay {
            switch toastType {
            case .spinner:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color(uiColor: .tertiarySystemGroupedBackground), lineWidth: 1.0)
            case .checkmark:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color.blue, lineWidth: 1.0)
                    .opacity(0.5)
            case .exclamation:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color.yellow, lineWidth: 1.0)
                    .opacity(0.5)
            case .persistentError:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color.red, lineWidth: 1.0)
                    .opacity(0.5)
            case .none:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(.primary, lineWidth: 1.0)
                    .opacity(0.5)
            }
        }
        .transition(AnyTransition.opacity)
    }

}
