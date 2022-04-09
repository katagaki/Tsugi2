//
//  BABusStopCellContentConfiguration.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import UIKit

struct BABusStopCellContentConfiguration: UIContentConfiguration {
    
    var busStop: BABusStop
    
    func makeContentView() -> UIView & UIContentView {
        return BABusStopCellContentView(self)
    }
    
    func updated(for state: UIConfigurationState) -> BABusStopCellContentConfiguration {
        return self
    }
    
}
