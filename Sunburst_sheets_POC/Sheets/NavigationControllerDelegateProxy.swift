//
//  NavigationControllerDelegateProxy.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit


final class NavigationControllerDelegateProxy : NSObject, UINavigationControllerDelegate {
    weak var proxiedDelegate: UINavigationControllerDelegate?
    weak var forwardingDelegate: SheetContentNavigationControllerDelegate?
    
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        if let sheetContentCustomizing = viewController as? SheetContentCustomizing {
            forwardingDelegate?.navigationController(navigationController, willShow: sheetContentCustomizing, animated: animated)
        }
        
        proxiedDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        if let sheetContentCustomizing = viewController as? SheetContentCustomizing {
            forwardingDelegate?.navigationController(navigationController, didShow: sheetContentCustomizing, animated: animated)
        }
        
        proxiedDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return proxiedDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }
    
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return proxiedDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .unknown
    }
    
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return proxiedDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }
    
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return proxiedDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}
