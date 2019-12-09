//
//  SheetBehavior.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 12/2/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit


public struct PositionInfo : Hashable {
    let position: SheetPosition
    let topInset: CGFloat?
}


public struct SheetPositionConfiguration {
    public let initialPosition: SheetPosition
    public let supportedPositions: Set<PositionInfo>
    public let snapAnimator: UIViewPropertyAnimator?
    
    let full: PositionInfo?
    let partialMax: PositionInfo?
    let partialDefault: PositionInfo?
    let offScreen: PositionInfo?
    
    public init(initialPosition: SheetPosition,
                supportedPositions: Set<PositionInfo>,
                snapAnimator: UIViewPropertyAnimator? = nil) {
        
        assert(supportedPositions.count > 0, "supportedPositions must contain at least one supported position")
        assert(supportedPositions.map { $0.position }.contains(initialPosition), "initial position must be inclused in the supported positions.")
        self.supportedPositions = supportedPositions
        self.initialPosition = initialPosition
        self.full = supportedPositions.first { $0.position == .full }
        self.partialMax = supportedPositions.first { $0.position == .partialMax }
        self.partialDefault = supportedPositions.first { $0.position == .partialDefault }
        self.offScreen = supportedPositions.first { $0.position == .offScreen }
        
        self.snapAnimator = snapAnimator
    }
}


// TODO:
// Method for actionsheet presentation
// preferred content size - KVO
public enum SheetBehavior {
    // Ratio or Specific height
    case panAndSnap(SheetPositionConfiguration)
    case fullOrDismissed
    case fixedHeight(CGFloat)
    
    public static func panAndSnapPartialMaxSheetBehavior(initialPosition: SheetPosition,
                                                         partialMaxTopInset: CGFloat,
                                                         partialDefaultTopIOnset: CGFloat,
                                                         offScreen: CGFloat?) -> SheetBehavior {
        
        let partialMax = PositionInfo(position: .partialMax, topInset: partialMaxTopInset)
        let partialDefault = PositionInfo(position: .partialDefault, topInset: partialDefaultTopIOnset)
        let offScreen = PositionInfo(position: .offScreen, topInset: offScreen)
        let configuration = SheetPositionConfiguration(initialPosition: initialPosition,
                                                       supportedPositions: Set([partialMax, partialDefault, offScreen]))
        
        return .panAndSnap(configuration)
    }
    
    
    public static func panAndSnapFullSheetBehavior(initialPosition: SheetPosition,
                                                   fullTopInset: CGFloat?,
                                                   partialDefaultTopInset: CGFloat,
                                                   offScreen: CGFloat?) -> SheetBehavior {
        let full = PositionInfo(position: .full, topInset: fullTopInset)
        let partialDefault = PositionInfo(position: .partialDefault, topInset: partialDefaultTopInset)
        let offScreen = PositionInfo(position: .offScreen, topInset: offScreen)
        
        let configuration = SheetPositionConfiguration(initialPosition: initialPosition,
                                                       supportedPositions: Set([full, partialDefault, offScreen]),
                                                       snapAnimator: nil)
        return .panAndSnap(configuration)
    }
    
    
    func sheetPosition(for origin: CGPoint, parentView: UIView) -> SheetPosition {
        switch self {
        case let .panAndSnap(sheetPositionConfiguration):
            
            if sheetPositionConfiguration.supportedPositions.count == 1,
                let firstSupportedPosition = sheetPositionConfiguration.supportedPositions.first {
                return firstSupportedPosition.position
            }
            
            // TODO: Support all possible cases
            // 1. Sort supported positions
            // 2. calculate thereshold for each
            // 3. find where the origin falls and return correct supported position
            let topInsetPartialMax = sheetPositionConfiguration.partialMax?.topInset ?? 64.0
            let topInsetPartialDefault = sheetPositionConfiguration.partialDefault?.topInset ?? 462.0
            let topInsetHidden = parentView.bounds.size.height
            
            // Calcurate threshold
            let partialDefaultThreshold = calculateThreshold(higherSnapPointY: topInsetPartialMax, lowerSnapPointY: topInsetPartialDefault)
            let hiddenThreshold = calculateThreshold(higherSnapPointY: topInsetPartialDefault, lowerSnapPointY: topInsetHidden)
            
            switch origin.y {
            case -CGFloat.greatestFiniteMagnitude..<partialDefaultThreshold:
                return .partialMax
            case partialDefaultThreshold..<hiddenThreshold:
                return .partialDefault
            default:
                return .offScreen
            }
            
        case .fullOrDismissed:
            switch origin.y {
            case 0.0...200:
                return .full
            default:
                return .offScreen
            }
            
        case .fixedHeight:
            return .partialDefault
        }
    }
    
    
    private func calculateThreshold(higherSnapPointY: CGFloat, lowerSnapPointY: CGFloat) -> CGFloat {
        return higherSnapPointY + (lowerSnapPointY - higherSnapPointY) / 2
    }
    
    
    func nextSupportedPosition(from position: SheetPosition, direction: SheetPositionDirection) -> SheetPosition {
        switch self {
        case let .panAndSnap(configuration):
            switch direction {
            case .up:
                return nextSupportedPosition(from: position, configuration: configuration)
            case .down:
                return previousSupportedPosition(from: position, configuration: configuration)
            }
        case .fullOrDismissed:
            // fullOrDismissed case is either full or dismissed
            return position
        case .fixedHeight:
            return position
        }
    }
    
    
    private func nextSupportedPosition(from position: SheetPosition, configuration: SheetPositionConfiguration) -> SheetPosition {
        return nextSupportedPosition(from: position, originalPosition: position, configuration: configuration)
    }
    
    
    private func nextSupportedPosition(from position: SheetPosition, originalPosition: SheetPosition, configuration: SheetPositionConfiguration) -> SheetPosition {
        guard let nextPosition = position.next else {
            return originalPosition
        }
        
        if configuration.supportedPositions.map({ $0.position }).contains(nextPosition) {
            return nextPosition
        } else {
            return nextSupportedPosition(from: nextPosition, originalPosition: originalPosition, configuration: configuration)
        }
    }
    
    
    private func previousSupportedPosition(from position: SheetPosition, configuration: SheetPositionConfiguration) -> SheetPosition {
        return previousSupportedPosition(from: position, originalPosition: position, configuration: configuration)
    }
    
    
    private func previousSupportedPosition(from position: SheetPosition, originalPosition: SheetPosition, configuration: SheetPositionConfiguration) -> SheetPosition {
        guard let previousPosition = position.previous else {
            return originalPosition
        }
        
        if configuration.supportedPositions.map({ $0.position }).contains(previousPosition) {
            return previousPosition
        } else {
            return previousSupportedPosition(from: previousPosition, originalPosition: originalPosition, configuration: configuration)
        }
    }
}
