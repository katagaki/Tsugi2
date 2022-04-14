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
        
    var busStops: [BusStop] = []
    
    var listConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
    lazy var listLayout: UICollectionViewCompositionalLayout = .list(using: listConfiguration)
    var dataSource: UICollectionViewDiffableDataSource<Section, ListItem>!
    var dataSourceSnapshot: NSDiffableDataSourceSnapshot<Section, ListItem> = .init()
    let indexTitles: [String] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".map { String($0) }
    
    var searchResults: [BusStop] = []
    lazy var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure layout
        listConfiguration.headerMode = .firstItemInSection
        listConfiguration.headerTopPadding = 8.0
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
        
        // Add MRT Service Map section with 1 cell
        var mrtServiceMapSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        let mrtServiceMapHeaderItem = ListItem.header("")
        mrtServiceMapSectionSnapshot.append([mrtServiceMapHeaderItem])
        mrtServiceMapSectionSnapshot.append([.mrtServiceMapItem("MRT Service Map")])
        mrtServiceMapSectionSnapshot.expand([mrtServiceMapHeaderItem])
        dataSource.apply(mrtServiceMapSectionSnapshot, to: .mrtServiceMap, animatingDifferences: false)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load bus stop data
        Task {
            let sampleBusStopsList = try await fetchBusStops()
            busStops.removeAll()
            busStops.append(contentsOf: sampleBusStopsList.busStops.sorted(by: { bS1, bS2 in
                bS1.description ?? "" < bS2.description ?? ""
            }))
            
            var busStopsSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
            let busStopsHeaderItem = ListItem.header("Bus Stops")
            busStopsSectionSnapshot.append([busStopsHeaderItem])
            for busStop: BusStop in busStops {
                let busStopItem = ListItem.busStopItem(busStop)
                busStopsSectionSnapshot.append([busStopItem])
            }
            busStopsSectionSnapshot.expand([busStopsHeaderItem])
            await dataSource.apply(busStopsSectionSnapshot, to: .busStops, animatingDifferences: true)
            
            dataSourceSnapshot.reloadSections([.busStops])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusStopDetails" {
            if let destination = segue.destination as? DTBusStopDetailsViewController,
               let sender = sender as? UICollectionViewCell,
               let indexPath = collectionView.indexPath(for: sender) {
                destination.busStop = busStops[indexPath.row - 1]
            } else {
                log("It seems like showBusStopDetails was called but did not receive the proper arguments.", level: .error)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1:
            if indexPath.row != 0 {
                performSegue(withIdentifier: "showBusStopDetails", sender: collectionView.cellForItem(at: indexPath))
            }
        default: break
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
//    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
//        return indexTitles
//    }
    
//    override func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
//        return IndexPath(row: indexTitles.firstIndex(of: String(Array(title)[0]).uppercased()) ?? 26, section: 1)
//    }
    
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
