//
//  SheetContentNavigationController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/20/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit


protocol SheetContentNavigationControllerDelegate : class {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: SheetContentCustomizing,
                              animated: Bool)
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: SheetContentCustomizing,
                              animated: Bool)
}


public class SheetContentNavigationController: UINavigationController {
    private let delegateProxy = NavigationControllerDelegateProxy()
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override public var delegate: UINavigationControllerDelegate? {
        get {
            return delegateProxy
        }
        
        set {
            delegateProxy.proxiedDelegate = newValue
        }
    }
    
    
    weak var sheetNavigationDelegate: SheetContentNavigationControllerDelegate? {
        get {
            return delegateProxy.forwardingDelegate
        }
        
        set {
            delegateProxy.forwardingDelegate = newValue
        }
    }
}


extension SheetContentNavigationController : SheetContentCustomizing {
    public var sheetBehavior: SheetBehavior {
        guard let topViewController = topViewController as? SheetContentCustomizing else {
            // FIXME:
            return SheetBehavior.panAndSnapPartialMaxSheetBehavior(initialPosition: .partialDefault,
                                                                   partialMaxTopInset: 64.0,
                                                                   partialDefaultTopIOnset: 462.0,
                                                                   offScreen: nil)
        }
        return topViewController.sheetBehavior
    }
}
