//
//  SheetPosition.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

enum SheetPosition : Int {
    case full
    case partialMax
    case partialDefault
    case hidden
}


struct SheetPositionHeightRatio: RawRepresentable, Hashable {
    var rawValue: CGFloat
    
    init(rawValue: SheetPositionHeightRatio.RawValue) {
        assert(rawValue >= 0, "rawValue must be value between 0 to 1")
        assert(rawValue <= 1, "rawValue must be value between 0 to 1")
        self.rawValue = rawValue
    }
    
    static let full = SheetPositionHeightRatio(rawValue: 1)
    static let partialMax = SheetPositionHeightRatio(rawValue: 0.8)
    static let partialDefault = SheetPositionHeightRatio(rawValue: 1)
    static let hidden = SheetPositionHeightRatio(rawValue: 0)
}


