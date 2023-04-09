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
                Image("AppIcon.Green")
                    .resizable()
                    .frame(width: 60.0, height: 60.0)
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 14.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.General.AppIcon.Green")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName(nil)
            }
            HStack(alignment: .center, spacing: 16.0) {
                Image("AppIcon.Red")
                    .resizable()
                    .frame(width: 60.0, height: 60.0)
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 14.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.General.AppIcon.Red")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName("Red")
            }
            HStack(alignment: .center, spacing: 16.0) {
                Image("AppIcon.Purple")
                    .resizable()
                    .frame(width: 60.0, height: 60.0)
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 14.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.General.AppIcon.Purple")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName("Purple")
            }
            HStack(alignment: .center, spacing: 16.0) {
                Image("AppIcon.Blue")
                    .resizable()
                    .frame(width: 60.0, height: 60.0)
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 14.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.General.AppIcon.Blue")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName("Blue")
            }
            HStack(alignment: .center, spacing: 16.0) {
                Image("AppIcon.Laze")
                    .resizable()
                    .frame(width: 60.0, height: 60.0)
                    .clipped(antialiased: true)
                    .mask {
                        RoundedRectangle(cornerRadius: 14.0)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14.0)
                            .stroke(.thickMaterial, lineWidth: 1.0)
                    }
                Text("More.General.AppIcon.Laze")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.setAlternateIconName("Laze")
            }
        }
        .font(.body)
        .listStyle(.insetGrouped)
        .navigationTitle("ViewTitle.More.General.AppIcon")
    }
}

struct MoreAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        MoreAppIconView()
    }
}
