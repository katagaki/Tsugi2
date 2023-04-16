//
//  DirectoryMRTMapView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import SwiftUI

struct DirectoryMRTMapView: View {
    var body: some View {
        WebView(url: URL(string: "https://www.lta.gov.sg/content/ltagov/en/map/train.html")!)
            .navigationTitle("ViewTitle.MRTMap")
    }
}

struct DirectoryMRTMapView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryMRTMapView()
    }
}
