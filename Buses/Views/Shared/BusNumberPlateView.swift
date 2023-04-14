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
                .font(Font.custom("OceanSansStd-Bold", fixedSize: fontSize()))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 6.0, leading: 8.0, bottom: 2.0, trailing: 8.0))
                .frame(minWidth: 0, maxWidth: .infinity)
                .lineLimit(1)
        }
        .background {
            Color("PlateColor")
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius()))
        }
        .frame(minWidth: width(), maxWidth: width(), minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
    
    func fontSize() -> Double {
        switch carouselDisplayMode {
        case .Full:
            return 24.0
        case .Small:
            return 20.0
        case .Minimal:
            return 16.0
        }
    }
    
    func cornerRadius() -> Double {
        switch carouselDisplayMode {
        case .Full:
            return 10.0
        case .Small:
            return 8.0
        case .Minimal:
            return 6.0
        }
    }
    
    func width() -> Double {
        switch carouselDisplayMode {
        case .Full:
            return 80.0
        case .Small:
            return 72.0
        case .Minimal:
            return 56.0
        }
    }
    
}
