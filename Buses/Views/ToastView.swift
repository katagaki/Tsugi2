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
                Image(systemName: "exclamationmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            case .PersistentError:
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            case .None:
                Color.clear
            }
            Text(message)
                .font(.body)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .mask {
            RoundedRectangle(cornerRadius: 8.0)
        }
        .shadow(radius: 2.5)
        .transition(AnyTransition.opacity)
    }
    
}

enum ToastType {
    case Spinner
    case Checkmark
    case Exclamation
    case PersistentError
    case None
}
