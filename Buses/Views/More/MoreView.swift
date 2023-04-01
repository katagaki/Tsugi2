//
//  MoreView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreView: View {
    
    @State var currentlySelectedStartupTab: Int = 0
    
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
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("ListIcon.Startup")
                            Text("More.StartupTab")
                                .font(.body)
                        }
                    }
                    NavigationLink {
                        MoreAppIconView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("ListIcon.AppIcon")
                            Text("More.AppIcon")
                                .font(.body)
                        }
                    }
                } header: {
                    Text("More.General")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                // TODO: Include some notification sounds, settings, etc
//                Section {
//                    NavigationLink {
//                        MoreNotificationsView()
//                    } label: {
//                        HStack(alignment: .center, spacing: 16.0) {
//                            Image("ListIcon.Notifications")
//                            Text("More.Notifications")
//                                .font(.body)
//                        }
//                    }
//                }
                Section {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("ListIcon.GitHub")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.Support.GitHub")
                                .font(.body)
                            Text("More.Support.GitHub.Subtitle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://github.com/katagaki/Tsugi2")!)
                    }
                    // TODO: Add donation options
//                    NavigationLink {
//                        MoreDonateView()
//                    } label: {
//                        HStack(alignment: .center, spacing: 16.0) {
//                            Image("ListIcon.Donate")
//                            Text("More.Support.Donate")
//                                .font(.body)
//                        }
//                    }
                } header: {
                    Text("More.Support")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                Section {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("ListIcon.Twitter")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.Help.Twitter")
                                .font(.body)
                            Text("More.Help.Twitter.Subtitle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://twitter.com/katagaki_")!)
                    }
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("ListIcon.Email")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.Help.Email")
                                .font(.body)
                            Text(verbatim: localized("More.Help.Email.Subtitle"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "mailto:ktgk.public@icloud.com")!)
                    }
                } header: {
                    Text("More.Help")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textCase(nil)
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
            .onAppear {
                currentlySelectedStartupTab = defaults.integer(forKey: "StartupTab")
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
