//
//  MoreView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        MoreStartupTabView()
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
                Section {
                    NavigationLink {
                        MoreNotificationsView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("ListIcon.Notifications")
                            Text("More.Notifications")
                                .font(.body)
                        }
                    }
                    .disabled(true) // TODO: To implement
                }
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
                    NavigationLink {
                        MoreDonateView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("ListIcon.Donate")
                            Text("More.Support.Donate")
                                .font(.body)
                        }
                    }
                    .disabled(true) // TODO: To implement
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
                    NavigationLink {
                        MoreAttributionView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("ListIcon.Attribution")
                            Text("More.Attribution")
                                .font(.body)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
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
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
