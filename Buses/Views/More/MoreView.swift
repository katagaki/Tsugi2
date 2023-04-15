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
                }
                Section {
                    HStack(alignment: .center, spacing: 0.0) {
                        Button {
                            settings.setCarouselDisplayMode(.Full)
                        } label: {
                            ImageWithCheck(image: "Carousel.Full",
                                           label: localized("More.Customization.CarouselSize.Full"),
                                           checked: $settings.carouselDisplayModeIsFull)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        Button {
                            settings.setCarouselDisplayMode(.Small)
                        } label: {
                            ImageWithCheck(image: "Carousel.Small",
                                           label: localized("More.Customization.CarouselSize.Small"),
                                           checked: $settings.carouselDisplayModeIsSmall)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        Button {
                            settings.setCarouselDisplayMode(.Minimal)
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
                        ListRow(image: "ListIcon.AppIcon", title: "More.Customization.AppIcon")
                    }
                    Toggle(isOn: $settings.useProperText) {
                        ListRow(image: "ListIcon.ProperText", title: "More.Customization.ProperText", subtitle: "More.Customization.ProperText.Subtitle")
                    }
                    .disabled(dataManager.shouldReloadBusStopList)
                } header: {
                    ListSectionHeader(text: "More.Customization")
                }
                // TODO: Include some notification sounds, settings, etc
                Section {
                    ListRow(image: "ListIcon.GitHub", title: "More.Support.GitHub", subtitle: "More.Support.GitHub.Subtitle", includeSpacer: true)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://github.com/katagaki/Tsugi2")!)
                    }
                    // TODO: Add donation options
                } header: {
                    ListSectionHeader(text: "More.Support")
                }
                Section {
                    ListRow(image: "ListIcon.Twitter", title: "More.Help.Twitter", subtitle: "More.Help.Twitter.Subtitle", includeSpacer: true)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://twitter.com/katagaki_")!)
                    }
                    ListRow(image: "ListIcon.Email", title: "More.Help.Email", subtitle: "More.Help.Email.Subtitle", includeSpacer: true)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "mailto:ktgk.public@icloud.com")!)
                    }
                } header: {
                    ListSectionHeader(text: "More.Help")
                }
                Section {
                } header: {
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text("Data in this app is provided by LTA's DataMall service. LTA's DataMall service provides live data about Singapore's roads and public transit services.\nDue to limitations in the LTA DataMall API, HTTPS is not used by the API.")
                        Link("Learn More", destination: URL(string: "https://datamall.lta.gov.sg/")!)
                    }
                    .font(.caption)
                    .textCase(.none)
                }
            }
            .listStyle(.insetGrouped)
            .onChange(of: settings.startupTab, perform: { newValue in
                settings.setStartupTab(newValue)
            })
            .onChange(of: settings.useProperText, perform: { newValue in
                settings.setProperText(newValue)
                dataManager.shouldReloadBusStopList = true
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

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
