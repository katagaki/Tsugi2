//
//  BUBusStopCarouselTableViewCell.swift
//  Buses
//
//  Created by 堅書 on 2022/04/03.
//

import UIKit

class BUBusStopCarouselTableViewCell: BUTableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let sampleBusStops:[String] = ["291", "888E", "21N", "4", "17"]
    let sampleTime1s:[String] = ["99 min", "10 min", "Arriving", "1 min", "Arriving"]
    let sampleTime2s:[String] = ["Arriving", "99 min", "1 min", "Arriving", "15 min"]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleBusStops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BUBusServiceCollectionViewCell", for: .init(row: 0, section: 0)) as! BUBusServiceCollectionViewCell
        cell.serviceNameLabel.text = sampleBusStops[indexPath.row]
        cell.arrivalTime1Label.text = sampleTime1s[indexPath.row]
        cell.arrivalTime2Label.text = sampleTime2s[indexPath.row]
        return cell
    }
    
    
}
