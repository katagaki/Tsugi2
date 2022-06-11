//
//  FavoritesHostingController.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import UIKit
import SwiftUI

class FavoritesHostingController: UIHostingController<FavoritesView> {

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder, rootView: FavoritesView())
    }
}
