//
//  BABusStopCarouselCellContentConfiguration.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import UIKit

struct BABusStopCarouselCellContentConfiguration: UIContentConfiguration {
    
    var busService: BABusService
    
    func makeContentView() -> UIView & UIContentView {
        return BABusStopCarouselCellContentView(self)
    }
    
    func updated(for state: UIConfigurationState) -> BABusStopCarouselCellContentConfiguration {
        return self
    }
    
}
