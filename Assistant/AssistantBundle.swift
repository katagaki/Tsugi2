//
//  AssistantBundle.swift
//  Assistant
//
//  Created by 堅書 on 27/2/23.
//

import WidgetKit
import SwiftUI

@main
struct AssistantBundle: WidgetBundle {
    var body: some Widget {
        Assistant()
        AssistantLiveActivity()
    }
}
