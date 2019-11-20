//
//  SheetContentNavigationController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/20/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

protocol SheetContentCustomizing: UIViewController {
    var sheetHeight: CGFloat { get set }
}

protocol SheetContentNavigationControllerDelegate : class {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: SheetContentCustomizing,
                              animated: Bool)
}

class SheetContentNavigationController: UINavigationController {

    private var externalDelegate: UINavigationControllerDelegate?
    weak var sheetNavigationDelegate: SheetContentNavigationControllerDelegate?
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        super.delegate = self
//    }
//
//    override init(rootViewController: UIViewController) {
//        super.init(rootViewController: rootViewController)
//        super.delegate = self
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        return nil
//    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override var delegate: UINavigationControllerDelegate? {
        get {
            return self
        }
        set {
            externalDelegate = newValue
        }
    }
    
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        super.pushViewController(viewController, animated: animated)
//    }
}


extension SheetContentNavigationController : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        externalDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        if let sheetContentCustmizing = viewController as? SheetContentCustomizing {
            sheetNavigationDelegate?.navigationController(navigationController, didShow: sheetContentCustmizing, animated: animated)
        }
        
        externalDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return externalDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }
    
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return externalDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .unknown
    }
    
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return externalDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }
    
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return externalDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}
