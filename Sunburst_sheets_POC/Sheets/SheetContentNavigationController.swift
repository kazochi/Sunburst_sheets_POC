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


class SheetContentNavigationController: UINavigationController {
    private let delegateProxy = NavigationControllerDelegateProxy()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override var delegate: UINavigationControllerDelegate? {
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
    var sheetHeight: CGFloat {
        guard let topViewController = topViewController as? SheetContentCustomizing else {
            return 0
        }
        return topViewController.sheetHeight
    }
}
