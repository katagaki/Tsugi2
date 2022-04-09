//
//  BABusStopCarouselCellContentView.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import UIKit

class BABusStopCarouselCellContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            self.configure(configuration: configuration)
        }
    }
    let serviceNameLabel: BULabel = BULabel()
    let arrivalTimeLabel: BULabel = BULabel()
    let arrivalTimeSubLabel: BULabel = BULabel()
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        self.addSubview(serviceNameLabel)
        self.addSubview(arrivalTimeLabel)
        self.addSubview(arrivalTimeSubLabel)
        
        serviceNameLabel.textAlignment = .center
        serviceNameLabel.leftPadding = 4.0
        serviceNameLabel.rightPadding = 4.0
        serviceNameLabel.topPadding = 5.0
        serviceNameLabel.font = UIFont(name: "OceanSansStd-Bold", size: 28.0)
        serviceNameLabel.textColor = .white
        serviceNameLabel.numberOfLines = 1
        serviceNameLabel.backgroundColor = .init(named: "PlateColor")
        serviceNameLabel.layer.cornerRadius = 7.0
        serviceNameLabel.clipsToBounds = true
        serviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            serviceNameLabel.widthAnchor.constraint(equalToConstant: 90.0),
            serviceNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0),
            serviceNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0),
            serviceNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0),
            serviceNameLabel.bottomAnchor.constraint(equalTo: self.arrivalTimeLabel.topAnchor, constant: -8.0)
        ])
        
        arrivalTimeLabel.textAlignment = .center
        arrivalTimeLabel.font = .preferredFont(forTextStyle: .body)
        arrivalTimeLabel.textColor = .label
        arrivalTimeLabel.numberOfLines = 1
        arrivalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrivalTimeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0),
            arrivalTimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0),
            arrivalTimeLabel.bottomAnchor.constraint(equalTo: self.arrivalTimeSubLabel.topAnchor, constant: -4.0)
        ])
        
        arrivalTimeSubLabel.textAlignment = .center
        arrivalTimeSubLabel.font = .preferredFont(forTextStyle: .body)
        arrivalTimeSubLabel.textColor = .secondaryLabel
        arrivalTimeSubLabel.numberOfLines = 1
        arrivalTimeSubLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrivalTimeSubLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0),
            arrivalTimeSubLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0),
            arrivalTimeSubLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16.0)
        ])
        
        self.configure(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? BABusStopCarouselCellContentConfiguration else { return }
        
        self.serviceNameLabel.text = configuration.busService.serviceNo
        self.arrivalTimeLabel.text = arrivalTimeTo(date: date(fromISO8601: configuration.busService.nextBus.estimatedArrivalTime)!)
        self.arrivalTimeSubLabel.text = arrivalTimeTo(date: date(fromISO8601: configuration.busService.nextBus2.estimatedArrivalTime)!)
    }
    
}
