//
//  MoreView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreView: View {
    
    @EnvironmentObject var busStopList: BusStopList
    @EnvironmentObject var shouldReloadBusStopList: BoolState
    
    @State var currentlySelectedStartupTab: Int = 0
    @State var useProperText: Bool = true
    
    @State var showLogsView: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(selection: $currentlySelectedStartupTab) {
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
                    NavigationLink {
                        MoreAppIconView()
                    } label: {
                        ListRow(image: "ListIcon.AppIcon", title: "More.General.AppIcon")
                    }
                } header: {
                    ListSectionHeader(text: "More.General")
                }
                Section {
                    Toggle(isOn: $useProperText) {
                        ListRow(image: "ListIcon.ProperText", title: "More.Customization.ProperText", subtitle: "More.Customization.ProperText.Subtitle")
                    }
                    .disabled(shouldReloadBusStopList.state)
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
            .onChange(of: currentlySelectedStartupTab, perform: { newValue in
                defaults.set(newValue, forKey: "StartupTab")
            })
            .onChange(of: useProperText, perform: { newValue in
                defaults.set(newValue, forKey: "UseProperText")
                shouldReloadBusStopList.state = true
            })
            .onAppear {
                currentlySelectedStartupTab = defaults.integer(forKey: "StartupTab")
                useProperText = defaults.bool(forKey: "UseProperText")
            }
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
                        .font(.system(size: 12.0))
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
