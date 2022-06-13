//
//  MoreView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        MoreAppIconView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("CellAppIcon")
                            Text("More.AppIcon")
                                .font(.body)
                        }
                    }
                    NavigationLink {
                        MoreNotificationsView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("CellNotifications")
                            Text("More.Notifications")
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
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellGitHub")
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
                            Image("CellDonate")
                            Text("More.Support.Donate")
                                .font(.body)
                        }
                    }
                } header: {
                    Text("More.Support")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                Section {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellTwitter")
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
                        Image("CellEmail")
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
            }
            .listStyle(.insetGrouped)
            .navigationTitle("ViewTitle.More")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
