//
//  MoreMenu.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreMenu: View {

    @Environment(NavigationManager.self) var navigationManager

    @AppStorage(SettingsKey.carouselDisplayMode) var carouselDisplayMode: CarouselDisplayMode = .full

    var body: some View {
        Menu {
            Section("More.Customization") {
                carouselDisplayModeToggle(.full, label: "More.Customization.CarouselSize.Full")
                carouselDisplayModeToggle(.small, label: "More.Customization.CarouselSize.Small")
                carouselDisplayModeToggle(.minimal, label: "More.Customization.CarouselSize.Minimal")
            }
            Section {
                Link(destination: URL(string: "https://github.com/katagaki/Tsugi2")!) {
                    Label("More.GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                Button {
                    navigationManager.push(ViewPath.moreLicenses)
                } label: {
                    Label("More.Attributions", systemImage: "doc.text")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .menuOrder(.fixed)
    }

    // An inline Picker drops the section's title in a menu, so each mode is a toggle instead
    func carouselDisplayModeToggle(_ mode: CarouselDisplayMode, label: LocalizedStringKey) -> some View {
        Toggle(label, isOn: Binding(
            get: { carouselDisplayMode == mode },
            set: { isOn in
                if isOn {
                    carouselDisplayMode = mode
                }
            }
        ))
    }

}
