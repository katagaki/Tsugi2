//
//  Toaster.swift
//  Buses
//
//  Created by 堅書 on 13/4/23.
//

import Foundation
import SwiftUI

class Toaster: ObservableObject {
    
    @Published var isToastShowing: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastType: ToastType = .None
    
    func showToast(_ message: String,
                   type: ToastType = .None,
                   hidesAutomatically: Bool = true) {
        DispatchQueue.main.async { [self] in
            toastMessage = message
            toastType = type
            isToastShowing = true
            if hidesAutomatically {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
                    isToastShowing = false
                }
            }
        }
    }
    
    func hideToast() {
        DispatchQueue.main.async { [self] in
            toastMessage = ""
            toastType = .None
            isToastShowing = false
        }
    }
    
}
