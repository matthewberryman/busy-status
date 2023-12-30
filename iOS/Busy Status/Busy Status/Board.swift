//
//  Item.swift
//  Busy Status
//
//  Created by Matthew Berryman on 21/12/2023.
//

import Foundation
import SwiftData


@Model
final class Board {
    var myUUID: UUID
    
    init(myUUID: UUID) {
        self.myUUID = myUUID
    }
}
