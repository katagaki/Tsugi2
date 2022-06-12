//
//  NearbyHostingController.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import UIKit
import SwiftUI

class NearbyHostingController: UIHostingController<NearbyView> {

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder, rootView: NearbyView())
    }
}
