//
//  DemoHomeViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 12/5/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class DemoHomeViewController: UIViewController {

    private var sheetController: SheetController?
    @IBOutlet private var coloredViews: [UIView] = []

    @IBOutlet weak var snapMaxButton: UIButton!
    @IBOutlet weak var snapFullButton: UIButton!
    @IBOutlet weak var fullOrDismissButton: UIButton!
    @IBOutlet weak var actionSheetButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        for view in coloredViews {
            view.layer.cornerRadius = 5
        }
    }
    
  
    @IBAction func presentSnapMaxSheet(_ sender: Any) {
        if sheetController?.parent == nil {
            let sheetBehavior = SheetBehavior.panAndSnapPartialMaxSheetBehavior(initialPosition: .partialDefault,
                                                                                partialMaxTopInset: 64.0,
                                                                                partialDefaultTopIOnset: 300,
                                                                                offScreen: nil)
            let childContentViewController = SheetContentViewController(sheetBehavior: sheetBehavior)
            
            let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
            sheetController = SheetController(contentViewController: navigationController)
            sheetController!.delegate = self
            sheetController!.add(toParent: self, animated: true)
        } else {
            sheetController?.removeFromParent(animated: true)
            sheetController = nil
        }
    }
    
    @IBAction func presentSnapFullSheet(_ sender: Any) {
        if sheetController?.parent == nil {
            let sheetBehavior = SheetBehavior.panAndSnapFullSheetBehavior(initialPosition: .partialDefault,
                                                                          fullTopInset: 0.0,
                                                                          partialDefaultTopInset: 462.0,
                                                                          offScreen: nil)
            let childContentViewController = SheetContentViewController(sheetBehavior: sheetBehavior)
            
            let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
            sheetController = SheetController(contentViewController: navigationController)
            sheetController!.delegate = self
            sheetController!.add(toParent: self, animated: true)
        } else {
            sheetController?.removeFromParent(animated: true)
            sheetController = nil
        }
    }
    
    @IBAction func presentfullOrDismissSheet(_ sender: Any) {
        if sheetController?.parent == nil {
            let sheetBehavior = SheetBehavior.fullOrDismissed
            let childContentViewController = SheetContentViewController(sheetBehavior: sheetBehavior)
            
            let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
            sheetController = SheetController(contentViewController: navigationController)
            sheetController!.delegate = self
            sheetController!.add(toParent: self, animated: true)
        } else {
            sheetController?.removeFromParent(animated: true)
            sheetController = nil
        }

    }
    
    
    @IBAction func presentNavigation(_ sender: Any) {
        if sheetController?.parent == nil {
            let childContentViewController = BackgroundColorScrollViewController()
            
            let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
            sheetController = SheetController(contentViewController: navigationController)
            sheetController!.delegate = self
            sheetController!.add(toParent: self, animated: true)
            sheetController!.track(scrollView: childContentViewController.scrollView)
        } else {
            sheetController?.removeFromParent(animated: true)
            sheetController = nil
        }
    }
    
    
    @IBAction func presentActionSheet(_ sender: Any) {
        let sheetBehavior = SheetBehavior.fullOrDismissed
        let childContentViewController = SheetContentViewController(sheetBehavior: sheetBehavior)
        let sheetViewController = SheetController(contentViewController: childContentViewController)
        sheetViewController.modalPresentationStyle = .custom
        present(sheetViewController, animated: true, completion: nil)
    }
}


extension DemoHomeViewController : SheetViewControllerDelegate {
    func sheetViewController(_ sheetViewController: SheetController, didUpdateSheetHeight sheetHeight: CGFloat, sheetPosition: SheetPosition) {
//        let contentInsetBottom = sheetHeight - view.safeAreaInsets.bottom
//        scrollView.contentInset.bottom = contentInsetBottom
//        scrollView.scrollIndicatorInsets.bottom = contentInsetBottom
//        
        //        let hideNavigationBar = (sheetPosition == .full || sheetPosition == .partialMax)
//        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: true)
//        title = sheetPosition.description
    }
}
