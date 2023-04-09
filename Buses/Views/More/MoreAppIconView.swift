//
//  MoreAppIconView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import SwiftUI

struct MoreAppIconView: View {
    
    var icons: [AppIcon] = [AppIcon(previewImageName: "AppIcon.Green", name: "More.General.AppIcon.Green"),
                            AppIcon(previewImageName: "AppIcon.Red", name: "More.General.AppIcon.Red", iconName: "Red"),
                            AppIcon(previewImageName: "AppIcon.Purple", name: "More.General.AppIcon.Purple", iconName: "Purple"),
                            AppIcon(previewImageName: "AppIcon.Blue", name: "More.General.AppIcon.Blue", iconName: "Blue"),
                            AppIcon(previewImageName: "AppIcon.Laze", name: "More.General.AppIcon.Laze", iconName: "Laze")]
    
    var body: some View {
        List {
            ForEach(icons, id: \.name) { icon in
                ListAppIconRow(image: icon.previewImageName, text: localized(icon.name), iconToSet: icon.iconName)
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
