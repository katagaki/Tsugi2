//
//  DirectoryCollectionViewController.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import UIKit

class DirectoryCollectionViewController: UICollectionViewController,
                                         UISearchBarDelegate,
                                         UISearchControllerDelegate,
                                         UISearchResultsUpdating {
        
    var sampleBusStops: [BusStop] = []
    
    var listConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
    lazy var listLayout: UICollectionViewCompositionalLayout = .list(using: listConfiguration)
    var dataSource: UICollectionViewDiffableDataSource<Section, ListItem>!
    var dataSourceSnapshot: NSDiffableDataSourceSnapshot<Section, ListItem> = .init()

    var searchResults: [BusStop] = []
    lazy var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load sample data
        if let sampleDataPath = Bundle.main.path(forResource: "BusStops", ofType: "json") {
            if let sampleBusStopsList: BSBusStopList? = decode(from: sampleDataPath) {
                sampleBusStops.append(contentsOf: sampleBusStopsList!.busStops.sorted(by: { bS1, bS2 in
                    bS1.description ?? "" < bS2.description ?? ""
                }))
            }
        }
        
        // Configure layout
        listConfiguration.headerMode = .firstItemInSection
        listConfiguration.headerTopPadding = 16.0
        listConfiguration.backgroundColor = .init(named: "DirectoryBackgroundColor")
        collectionView.collectionViewLayout = listLayout
        
        // Register cells
        let headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, string in
            var content = cell.defaultContentConfiguration()
            content.text = string
            content.textProperties.color = .label
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.textProperties.adjustsFontForContentSizeCategory = true
            cell.contentConfiguration = content
            // cell.accessories = [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header))]
        }
        let mrtServiceMapCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, string in
            var content = cell.defaultContentConfiguration()
            content.text = string
            content.image = .init(named: "CellTrainMap")
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator(displayed: .whenNotEditing)]
        }
        let busStopCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BusStop> { cell, indexPath, busStop in
            var content = cell.defaultContentConfiguration()
            content.text = busStop.description
            content.secondaryText = busStop.roadName
            content.image = .init(named: "CellBusStop")
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator(displayed: .whenNotEditing)]
        }
        
        // Set up data source
        dataSource = UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: collectionView) {
            collectionView, indexPath, listItem -> UICollectionViewCell? in
            switch listItem {
            case .header(let string): return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: string)
            case .mrtServiceMapItem(let string): return collectionView.dequeueConfiguredReusableCell(using: mrtServiceMapCellRegistration, for: indexPath, item: string)
            case .busStopItem(let busStop): return collectionView.dequeueConfiguredReusableCell(using: busStopCellRegistration, for: indexPath, item: busStop)
            }
        }
        
        // Configure snapshots
        dataSourceSnapshot.appendSections([.mrtServiceMap, .busStops])
        dataSource.apply(dataSourceSnapshot)
        
        var mrtServiceMapSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        let mrtServiceMapHeaderItem = ListItem.header("")
        mrtServiceMapSectionSnapshot.append([mrtServiceMapHeaderItem])
        mrtServiceMapSectionSnapshot.append([.mrtServiceMapItem("MRT Service Map")])
        mrtServiceMapSectionSnapshot.expand([mrtServiceMapHeaderItem])
        dataSource.apply(mrtServiceMapSectionSnapshot, to: .mrtServiceMap, animatingDifferences: false)
        
        var busStopsSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        let busStopsHeaderItem = ListItem.header("Bus Stops")
        busStopsSectionSnapshot.append([busStopsHeaderItem])
        for busStop: BusStop in sampleBusStops {
            let busStopItem = ListItem.busStopItem(busStop)
            busStopsSectionSnapshot.append([busStopItem])
        }
        busStopsSectionSnapshot.expand([busStopsHeaderItem])
        dataSource.apply(busStopsSectionSnapshot, to: .busStops, animatingDifferences: false)
        
        // Configure search
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .label
        searchController.automaticallyShowsCancelButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
    
    enum Section: Hashable {
        case mrtServiceMap
        case busStops
    }
    
    enum ListItem: Hashable {
        case header(String)
        case mrtServiceMapItem(String)
        case busStopItem(BusStop)
    }
    
}
