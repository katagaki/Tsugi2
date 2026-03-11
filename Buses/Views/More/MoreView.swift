//
//  MoreView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster

    @State var showLogsView: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.moreTabPath) {
            List {
                Section {
                    HStack(alignment: .center, spacing: 0.0) {
                        Button {
                            settings.setCarouselDisplayMode(.full)
                        } label: {
                            ImageWithCheck(image: "Carousel.Full",
                                           label: localized("More.Customization.CarouselSize.Full"),
                                           checked: $settings.carouselDisplayModeIsFull)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        Button {
                            settings.setCarouselDisplayMode(.small)
                        } label: {
                            ImageWithCheck(image: "Carousel.Small",
                                           label: localized("More.Customization.CarouselSize.Small"),
                                           checked: $settings.carouselDisplayModeIsSmall)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        Button {
                            settings.setCarouselDisplayMode(.minimal)
                        } label: {
                            ImageWithCheck(image: "Carousel.Minimal",
                                           label: localized("More.Customization.CarouselSize.Minimal"),
                                           checked: $settings.carouselDisplayModeIsMinimal)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                    }
                    NavigationLink("More.Customization.AppIcon", value: ViewPath.moreAppIcon)
                    Toggle("More.Customization.ShowRoute", isOn: $settings.showRoute)
                    Toggle("More.Customization.ProperText", isOn: $settings.useProperText)
                        .disabled(dataManager.shouldReloadBusStopList)
                } header: {
                    Text("More.Customization")
                }
                Section {
                    Link(destination: URL(string: "https://github.com/katagaki/Tsugi2")!) {
                        HStack {
                            Text(String(localized: "More.GitHub"))
                            Spacer()
                            Text("katagaki/Tsugi2")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                    NavigationLink("More.Attributions", value: ViewPath.moreLicenses)
                }
            }
            .listStyle(.insetGrouped)
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .moreAppIcon:
                    MoreAppIconView()
                case .moreLicenses:
                    MoreLicensesView()
                default:
                    Color.clear
                }
            })
            .onChange(of: settings.useProperText, { _, newValue in
                settings.setProperText(newValue)
                dataManager.shouldReloadBusStopList = true
            })
            .onChange(of: settings.showRoute, { _, newValue in
                settings.setShowRoute(newValue)
            })
            .navigationTitle("ViewTitle.More")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLogsView) {
                NavigationStack {
                    TextEditor(text: .constant(appLogs))
                        .font(.system(size: 10.0))
                        .monospaced()
                        .navigationTitle("More.UnderTheHood")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}
