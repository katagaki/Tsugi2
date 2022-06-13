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
                Section(header: Text("More.General")) {
                    NavigationLink {
                        MoreAppIconView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("CellAppIcon")
                            Text("More.AppIcon")
                                .font(.body)
                                .fontWeight(.regular)
                        }
                    }
                    NavigationLink {
                        MoreNotificationsView()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("CellNotifications")
                            Text("More.Notifications")
                                .font(.body)
                                .fontWeight(.regular)
                        }
                    }
                }
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .textCase(nil)
                Section(header: Text("More.Support")) {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellGitHub")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.Support.GitHub")
                                .font(.body)
                                .fontWeight(.regular)
                            Text("More.Support.GitHub.Subtitle")
                                .font(.caption)
                                .fontWeight(.regular)
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
                                .fontWeight(.regular)
                        }
                    }
                }
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .textCase(nil)
                Section(header: Text("More.Help")) {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellTwitter")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.Help.Twitter")
                                .font(.body)
                                .fontWeight(.regular)
                            Text("More.Help.Twitter.Subtitle")
                                .font(.caption)
                                .fontWeight(.regular)
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
                                .fontWeight(.regular)
                            Text(verbatim: localized("More.Help.Email.Subtitle"))
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "mailto:ktgk.public@icloud.com")!)
                    }
                }
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .textCase(nil)
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
