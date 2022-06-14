//
//  BusNumberPlateView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/14.
//

import SwiftUI

struct BusNumberPlateView: View {
    
    @State var serviceNo: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text(serviceNo)
                .font(Font.custom("OceanSansStd-Bold", fixedSize: 24.0))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 6.0, leading: 16.0, bottom: 2.0, trailing: 16.0))
                .frame(minWidth: 0, maxWidth: .infinity)
                .lineLimit(1)
        }
        .background(Color("PlateColor"))
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}

struct BusNumberPlateView_Previews: PreviewProvider {
    static var previews: some View {
        BusNumberPlateView(serviceNo: "901M")
    }
}
