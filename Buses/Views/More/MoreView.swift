//
//  MoreView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreView: View {

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster

    @State var showLogsView: Bool = false

    var body: some View {
        NavigationStack {
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
                    NavigationLink {
                        MoreAppIconView()
                    } label: {
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
                    Link(destination: URL(string: "https://twitter.com/katagaki_")!) {
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
                    Link(destination: URL(string: "https://datamall.lta.gov.sg")!) {
                        HStack {
                            ListRow(image: "ListIcon.Attribution.LTA",
                                    title: "More.Attribution.LTA",
                                    includeSpacer: true)
                            Image(systemName: "safari")
                                .opacity(0.5)
                        }
                    }
                    .foregroundColor(.primary)
                    Link(destination: URL(string: "https://github.com/cheeaun/sgbusdata")!) {
                        HStack {
                            ListRow(image: "ListIcon.Attribution.BusRouter",
                                    title: "More.Attribution.BusRouter",
                                    includeSpacer: true)
                            Image(systemName: "safari")
                                .opacity(0.5)
                        }
                    }
                    .foregroundColor(.primary)
                    NavigationLink {
                        TextEditor(text: .constant(
"""
The MIT License (MIT)

Copyright (c) 2015 Raphaël Mor

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
                        ))
                        .navigationTitle("More.Attribution.Polyline")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Link(destination: URL(string: "https://github.com/raphaelmor/Polyline")!) {
                                    Image(systemName: "safari")
                                }
                            }
                        }
                    } label: {
                        ListRow(image: "ListIcon.Attribution.Polyline",
                                title: "More.Attribution.Polyline")
                    }
                } header: {
                    ListSectionHeader(text: "More.Attribution")
                        .font(.body)
                }
            }
            .listStyle(.insetGrouped)
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
                        .onTapGesture(count: 5) {
                            showLogsView = true
                        }
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
