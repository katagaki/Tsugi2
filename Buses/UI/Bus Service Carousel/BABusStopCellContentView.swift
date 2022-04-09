//
//  BABusStopCellContentView.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import UIKit

class BABusStopCellContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            self.configure(configuration: configuration)
        }
    }
    var carouselLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    lazy var carouselView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: carouselLayout)
    var dataSource: UICollectionViewDiffableDataSource<Section, BABusService>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, BABusService>!
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        self.addSubview(carouselView)
        
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.sectionInset.top = 0.0
        carouselLayout.sectionInset.bottom = 0.0
        carouselLayout.sectionInset.left = 8.0
        carouselLayout.sectionInset.right = 8.0
        carouselLayout.estimatedItemSize.width = 128.0
        carouselLayout.estimatedItemSize.height = 120.0
        carouselLayout.minimumInteritemSpacing = 0.0
        carouselLayout.minimumLineSpacing = 0.0
        carouselView.showsVerticalScrollIndicator = false
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint: NSLayoutConstraint = carouselView.heightAnchor.constraint(equalToConstant: 120.0)
        heightConstraint.priority -= 1
        NSLayoutConstraint.activate([
            heightConstraint,
            carouselView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0),
            carouselView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0),
            carouselView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0),
            carouselView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0)
        ])
        
        self.configure(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? BABusStopCellContentConfiguration else { return }
        
        // Register cells
        let busStopCarouselCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BABusService> {
            cell, indexPath, busService in
            let content = BABusStopCarouselCellContentConfiguration(busService: busService)
            cell.contentConfiguration = content
        }
        
        // Set up data source
        dataSource = UICollectionViewDiffableDataSource<Section, BABusService>(collectionView: carouselView) {
            collectionView, indexPath, busService -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: busStopCarouselCellRegistration, for: indexPath, item: busService)
            return cell
        }
        
        // Configure snapshots
        snapshot = NSDiffableDataSourceSnapshot<Section, BABusService>()
        snapshot.appendSections([.carousel])
        snapshot.appendItems(configuration.busStop.busServices, toSection: .carousel)
        dataSource.apply(snapshot)
    }
    
    enum Section {
        case carousel
    }
    
}
