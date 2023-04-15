//
//  ToastView.swift
//  Buses
//
//  Created by 堅書 on 16/7/22.
//

import SwiftUI

struct ToastView: View {
    
    var message: String
    var toastType: ToastType = .Spinner
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            switch toastType {
            case .Spinner:
                ProgressView()
                    .progressViewStyle(.circular)
            case .Checkmark:
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            case .Exclamation:
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
            case .PersistentError:
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            case .None:
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
            case .Spinner:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color(uiColor: .tertiarySystemGroupedBackground), lineWidth: 1.0)
            case .Checkmark:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color.blue, lineWidth: 1.0)
                    .opacity(0.5)
            case .Exclamation:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color.yellow, lineWidth: 1.0)
                    .opacity(0.5)
            case .PersistentError:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(Color.red, lineWidth: 1.0)
                    .opacity(0.5)
            case .None:
                RoundedRectangle(cornerRadius: 10.0)
                    .strokeBorder(.primary, lineWidth: 1.0)
                    .opacity(0.5)
            }
        }
        .transition(AnyTransition.opacity)
    }
    
}
