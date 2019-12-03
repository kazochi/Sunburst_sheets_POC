//
//  SheetBehavior.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 12/2/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

protocol SheetBehavior {
    var initialPosition: SheetPosition { get }
    var supportedPositions: Set<SheetPosition> { get }
    func topInset(for position: SheetPosition, relativeTo: UIView) -> CGFloat
    func position(for origin: CGPoint, in view: UIView) -> SheetPosition
}


class ScrollAndSnapSheetBehavior: SheetBehavior {
    let initialPosition: SheetPosition
    let supportedPositions: Set<SheetPosition>
    
    init(initialPosition: SheetPosition, supportedPositions: Set<SheetPosition>) {
        self.initialPosition = initialPosition
        self.supportedPositions = supportedPositions
    }
    
    func topInset(for position: SheetPosition, relativeTo view: UIView) -> CGFloat {
        switch position {
        case .full:
            return 0.0
        case .partialMax:
            return 64.0
        case .partialDefault:
            return 462.0
        case .hidden:
            return view.bounds.size.height
        }
    }
    
    static func makeFullScrollAndSnapBehavior() -> ScrollAndSnapSheetBehavior {
        return ScrollAndSnapSheetBehavior(initialPosition: .partialDefault, supportedPositions: [.hidden, .partialDefault, .full])
    }
    
    static func makePartialMaxScrollAndSnapBehavior() -> ScrollAndSnapSheetBehavior {
        return ScrollAndSnapSheetBehavior(initialPosition: .partialDefault, supportedPositions: [.hidden, .partialDefault, .partialDefault])
    }
    
    
    func position(for origin: CGPoint, in view: UIView) -> SheetPosition {
        let topInsetPartialFull = topInset(for: .full, relativeTo: view)
        let topInsetPartialMax = topInset(for: .partialMax, relativeTo: view)
        let topInsetPartialDefault = topInset(for: .partialDefault, relativeTo: view)
        let topInsetHidden = topInset(for: .hidden, relativeTo: view)
        
        // Calcurate threshold
        let fullThreshold = calculateThreshold(higherSnapPointY: topInsetPartialFull, lowerSnapPointY: topInsetPartialMax)
        let partialMaxThreshold = calculateThreshold(higherSnapPointY: topInsetPartialFull, lowerSnapPointY: topInsetPartialMax)
        let partialDefaultThreshold = calculateThreshold(higherSnapPointY: topInsetPartialMax, lowerSnapPointY: topInsetPartialDefault)
        let hiddenThreshold = calculateThreshold(higherSnapPointY: topInsetPartialDefault, lowerSnapPointY: topInsetHidden)
        
        switch origin.y {
        case -CGFloat.greatestFiniteMagnitude..<fullThreshold:
            return .full
        case partialMaxThreshold..<partialDefaultThreshold:
            return .partialMax
        case partialDefaultThreshold..<hiddenThreshold:
            return .partialDefault
        default:
            return .hidden
        }
    }
    
    
    private func calculateThreshold(higherSnapPointY: CGFloat, lowerSnapPointY: CGFloat) -> CGFloat {
        return higherSnapPointY + (lowerSnapPointY - higherSnapPointY) / 2
    }
}
