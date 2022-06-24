//
//  MoreStartupTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/14.
//

import SwiftUI

struct MoreStartupTabView: View {
    
    let defaults = UserDefaults.standard
    
    @State var currentlySelectedItem: Int = 0
    
    var body: some View {
        List {
            HStack(spacing: 16.0) {
                Image("ListIcon.Tab.Nearby")
                    .resizable()
                    .frame(width: 30.0, height: 30.0)
                Text("TabTitle.Nearby")
                    .font(.body)
                Spacer()
                if currentlySelectedItem == 0 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16.0, weight: .regular))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                defaults.set(0, forKey: "StartupTab")
                currentlySelectedItem = 0
            }
            HStack(spacing: 16.0) {
                Image("ListIcon.Tab.Locations")
                    .resizable()
                    .frame(width: 30.0, height: 30.0)
                Text("TabTitle.Favorites")
                    .font(.body)
                Spacer()
                if currentlySelectedItem == 1 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16.0, weight: .regular))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                defaults.set(1, forKey: "StartupTab")
                currentlySelectedItem = 1
            }
            HStack(spacing: 16.0) {
                Image("ListIcon.Tab.Notifications")
                    .resizable()
                    .frame(width: 30.0, height: 30.0)
                Text("TabTitle.Notifications")
                    .font(.body)
                Spacer()
                if currentlySelectedItem == 2 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16.0, weight: .regular))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                defaults.set(2, forKey: "StartupTab")
                currentlySelectedItem = 2
            }
            HStack(spacing: 16.0) {
                Image("ListIcon.Tab.Search")
                    .resizable()
                    .frame(width: 30.0, height: 30.0)
                Text("TabTitle.Directory")
                    .font(.body)
                Spacer()
                if currentlySelectedItem == 3 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16.0, weight: .regular))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                defaults.set(3, forKey: "StartupTab")
                currentlySelectedItem = 3
            }
        }
        .onAppear {
            currentlySelectedItem = defaults.integer(forKey: "StartupTab")
        }
        .navigationTitle("ViewTitle.More.StartupTab")
    }
}

struct MoreStartupTabView_Previews: PreviewProvider {
    static var previews: some View {
        MoreStartupTabView()
    }
}
