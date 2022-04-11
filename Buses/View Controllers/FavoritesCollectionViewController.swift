//
//  FavoritesCollectionViewController.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import UIKit

class FavoritesCollectionViewController: UICollectionViewController {
    
    var sampleBusStops: [BABusStop] = []
    
    var listConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
    lazy var listLayout: UICollectionViewCompositionalLayout = .list(using: listConfiguration)
    var dataSource: UICollectionViewDiffableDataSource<BABusStop, ListItem>!
    var dataSourceSnapshot: NSDiffableDataSourceSnapshot<BABusStop, ListItem> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load sample data
        if let sampleDataPath1 = Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json"),
           let sampleDataPath2 = Bundle.main.path(forResource: "BusArrivalv2-2", ofType: "json"),
           let sampleDataPath3 = Bundle.main.path(forResource: "BusArrivalv2-3", ofType: "json") {
            let sampleBusStop1: BABusStop? = decode(from: sampleDataPath1)
            let sampleBusStop2: BABusStop? = decode(from: sampleDataPath2)
            let sampleBusStop3: BABusStop? = decode(from: sampleDataPath3)
            sampleBusStops.append(contentsOf: [sampleBusStop1!, sampleBusStop2!, sampleBusStop3!])
        }
        
        // Configure layout
        listConfiguration.headerMode = .firstItemInSection
        listConfiguration.headerTopPadding = 16.0
        collectionView.collectionViewLayout = listLayout
        
        // Register cells
        let headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BABusStop> { cell, indexPath, busStop in
            var content = cell.defaultContentConfiguration()
            content.text = busStop.code
            content.textProperties.color = .label
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.textProperties.adjustsFontForContentSizeCategory = true
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header))]
        }
        let carouselCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BABusStop> { cell, indexPath, busStop in
            let content = BABusStopCellContentConfiguration(busStop: busStop)
            cell.contentConfiguration = content
        }
        
        // Set up data source
        dataSource = UICollectionViewDiffableDataSource<BABusStop, ListItem>(collectionView: collectionView) {
            collectionView, indexPath, listItem -> UICollectionViewCell? in
            switch listItem {
            case .header(let busStop): return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: busStop)
            case .item(let busStop): return collectionView.dequeueConfiguredReusableCell(using: carouselCellRegistration, for: indexPath, item: busStop)
            }
        }
        
        // Configure snapshots
        dataSourceSnapshot.appendSections(sampleBusStops)
        dataSource.apply(dataSourceSnapshot)
        
        for busStop: BABusStop in sampleBusStops {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
            let headerItem = ListItem.header(busStop)
            sectionSnapshot.append([headerItem])
            let carouselItem = ListItem.item(busStop)
            sectionSnapshot.append([carouselItem], to: headerItem)
            sectionSnapshot.expand([headerItem])
            dataSource.apply(sectionSnapshot, to: busStop, animatingDifferences: false)
        }
    }
    
    enum ListItem: Hashable {
        case header(BABusStop)
        case item(BABusStop)
    }
    
}
