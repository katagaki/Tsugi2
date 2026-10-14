//
//  MoreView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct MoreView: View {

    @Environment(\.dismiss) var dismiss

    @AppStorage(SettingsKey.carouselDisplayMode) var carouselDisplayMode: CarouselDisplayMode = .full
    @AppStorage(SettingsKey.showRoute) var showRoute: Bool = false
    @Environment(Toaster.self) var toaster

    @State var showLogsView: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(alignment: .center, spacing: 0.0) {
                        Button {
                            carouselDisplayMode = .full
                        } label: {
                            ImageWithCheck(image: "Carousel.Full",
                                           label: localized("More.Customization.CarouselSize.Full"),
                                           checked: carouselDisplayMode == .full)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        Button {
                            carouselDisplayMode = .small
                        } label: {
                            ImageWithCheck(image: "Carousel.Small",
                                           label: localized("More.Customization.CarouselSize.Small"),
                                           checked: carouselDisplayMode == .small)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        Button {
                            carouselDisplayMode = .minimal
                        } label: {
                            ImageWithCheck(image: "Carousel.Minimal",
                                           label: localized("More.Customization.CarouselSize.Minimal"),
                                           checked: carouselDisplayMode == .minimal)
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                    }
                    Toggle("More.Customization.ShowRoute", isOn: $showRoute)
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
            .navigationDestination(for: ViewPath.self) { viewPath in
                switch viewPath {
                case .moreLicenses:
                    MoreLicensesView()
                default:
                    Color.clear
                }
            }
            .navigationTitle("ViewTitle.More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
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
