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
                    Picker(selection: $settings.startupTab) {
                        Text("TabTitle.Nearby")
                            .tag(0)
                        Text("TabTitle.Favorites")
                            .tag(1)
                        Text("TabTitle.Notifications")
                            .tag(2)
                        Text("TabTitle.Directory")
                            .tag(3)
                    } label: {
                        ListRow(image: "ListIcon.Startup", title: "More.General.StartupTab")
                    }

                } header: {
                    ListSectionHeader(text: "More.General")
                        .font(.body)
                }
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
                    NavigationLink(value: ViewPath.moreAppIcon) {
                        ListRow(image: "ListIcon.AppIcon",
                                title: "More.Customization.AppIcon")
                    }
                    Toggle(isOn: $settings.showRoute) {
                        ListRow(image: "ListIcon.Route",
                                title: "More.Customization.ShowRoute",
                                subtitle: "More.Customization.ShowRoute.Subtitle")
                    }
                    Toggle(isOn: $settings.useProperText) {
                        ListRow(image: "ListIcon.ProperText",
                                title: "More.Customization.ProperText",
                                subtitle: "More.Customization.ProperText.Subtitle")
                    }
                    .disabled(dataManager.shouldReloadBusStopList)
                } header: {
                    ListSectionHeader(text: "More.Customization")
                        .font(.body)
                }
                // TODO: Include some notification sounds, settings, etc
                Section {
                    Link(destination: URL(string: "https://x.com/katagaki_")!) {
                        HStack {
                            ListRow(image: "ListIcon.Twitter",
                                    title: "More.Help.Twitter",
                                    subtitle: "More.Help.Twitter.Subtitle",
                                    includeSpacer: true)
                            Image(systemName: "safari")
                                .opacity(0.5)
                        }
                        .foregroundColor(.primary)
                    }
                    Link(destination: URL(string: "mailto:ktgk.public@icloud.com")!) {
                        HStack {
                            ListRow(image: "ListIcon.Email",
                                    title: "More.Help.Email",
                                    subtitle: "More.Help.Email.Subtitle",
                                    includeSpacer: true)
                            Image(systemName: "arrow.up.forward.app")
                                .opacity(0.5)
                        }
                        .foregroundColor(.primary)
                    }
                    Link(destination: URL(string: "https://github.com/katagaki/Tsugi2")!) {
                        HStack {
                            ListRow(image: "ListIcon.GitHub",
                                    title: "More.Help.GitHub",
                                    subtitle: "More.Help.GitHub.Subtitle",
                                    includeSpacer: true)
                            Image(systemName: "safari")
                                .opacity(0.5)
                        }
                        .foregroundColor(.primary)
                    }
                } header: {
                    ListSectionHeader(text: "More.Help")
                        .font(.body)
                }
                Section {
                    NavigationLink(value: ViewPath.moreAttributions) {
                        ListRow(image: "ListIcon.Attributions",
                                title: "More.Attribution")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .moreAppIcon:
                    MoreAppIconView()
                case .moreAttributions:
                    LicensesView()
                default:
                    Color.clear
                }
            })
            .onChange(of: settings.startupTab, { _, newValue in
                settings.setStartupTab(newValue)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ViewTitle.More")
                        .font(.system(size: 24.0, weight: .bold))
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
                }
            }
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
