//
//  SheetPosition.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

enum SheetPositionDirection : Int {
    case up
    case down
}

enum SheetPosition : Int, CustomStringConvertible {
    case full
    case partialMax
    case partialDefault
    case offScreen
    
    static var allCases: Set<SheetPosition> {
        return [.full, .partialMax, .partialDefault, .offScreen]
    }
    
    private var sortedCases: [SheetPosition] {
        return [.offScreen, .partialDefault, .partialMax, .full]
    }
    
    var next: SheetPosition? {
        guard let currentIndex = sortedCases.firstIndex(of: self), currentIndex+1 < sortedCases.count else {
            return nil
        }
        return sortedCases[currentIndex+1]
    }
    
    var previous: SheetPosition? {
        guard let currentIndex = sortedCases.firstIndex(of: self), currentIndex-1 >= 0 else {
            return nil
        }
        return sortedCases[currentIndex-1]
    }
    
    var description: String {
        switch self {
        case .full:
            return "full"
        case .partialMax:
            return "partialMax"
        case .partialDefault:
            return "partialDefault"
        case .offScreen:
            return "offScreen"
        }
    }
}

