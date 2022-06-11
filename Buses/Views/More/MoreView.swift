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
                Section(header: Text("")) {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellNotifications")
                        Text("More.Notifications")
                            .font(.body)
                            .fontWeight(.regular)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .textCase(nil)
                Section(header: Text("More.About")) {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellGitHub")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.AboutGitHub")
                                .font(.body)
                                .fontWeight(.regular)
                            Text("More.AboutGitHub.Subtitle")
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellTwitter")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.AboutTwitter")
                                .font(.body)
                                .fontWeight(.regular)
                            Text("More.AboutTwitter.Subtitle")
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellEmail")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("More.AboutEmail")
                                .font(.body)
                                .fontWeight(.regular)
                            Text(verbatim: localized("More.AboutEmail.Subtitle"))
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .textCase(nil)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("ViewTitle.More")
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
