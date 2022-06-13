//
//  MoreAppIconView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import SwiftUI

struct MoreAppIconView: View {
    var body: some View {
        List {
            HStack(alignment: .center, spacing: 16.0) {
                Image("AppIconGreen")
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 16.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.AppIcon.Green")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName(nil)
            }
            HStack(alignment: .center, spacing: 16.0) {
                Image("AppIconRed")
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 16.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.AppIcon.Red")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName("Red")
            }
            HStack(alignment: .center, spacing: 16.0) {
                Image("AppIconPurple")
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 16.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.AppIcon.Purple")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName("Purple")
            }
        }
        .font(.body)
        .listStyle(.insetGrouped)
        .navigationTitle("ViewTitle.More.AppIcon")
    }
}

struct MoreAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        MoreAppIconView()
    }
}