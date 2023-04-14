//
//  BusNumberPlateView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/14.
//

import SwiftUI

struct BusNumberPlateView: View {
    
    @Binding var carouselDisplayMode: CarouselDisplayMode
    
    @State var serviceNo: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text(serviceNo)
                .font(Font.custom("OceanSansStd-Bold", fixedSize: carouselDisplayMode.fontSize()))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 6.0, leading: 8.0, bottom: 2.0, trailing: 8.0))
                .frame(minWidth: 0, maxWidth: .infinity)
                .lineLimit(1)
        }
        .background {
            Color("PlateColor")
                .clipShape(RoundedRectangle(cornerRadius: carouselDisplayMode.cornerRadius()))
        }
        .frame(minWidth: carouselDisplayMode.width(), maxWidth: carouselDisplayMode.width(), minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
    
}
