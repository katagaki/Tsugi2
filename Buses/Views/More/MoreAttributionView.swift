//
//  MoreAttributionView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/14.
//

import SwiftUI

struct MoreAttributionView: View {
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Data in this app is provided by LTA's DataMall service. LTA's DataMall service provides live data about Singapore's roads and public transit services.")
                    .font(.body)
                Button(role: .none, action: {
                    UIApplication.shared.open(URL(string: "https://datamall.lta.gov.sg/")!)
                }, label: {
                    Text("Learn More")
                })
                    .buttonStyle(.bordered)
                Text("Due to limitations in the LTA DataMall API, HTTPS is not used by the API.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("ViewTitle.More.Attribution")
    }
}

struct MoreAttributionView_Previews: PreviewProvider {
    static var previews: some View {
        MoreAttributionView()
    }
}
