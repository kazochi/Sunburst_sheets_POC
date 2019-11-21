//
//  SheetViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/19/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

protocol SheetViewControllerDelegate: AnyObject {
    func sheetViewController(_ sheetViewController: SheetViewController, didUpdateSheetHeight: CGFloat)
}


final class SheetViewController : UIViewController {
    let position: SheetPosition = .hidden
    let sheetView: SheetView
    var sheetViewTopConstraint: NSLayoutConstraint!
    weak var delegate: SheetViewControllerDelegate?
    private let panGestureRecognizer: UIPanGestureRecognizer
    private let childViewController: SheetContentCustomizing
    private let passThroughView: PassThroughView
    private var initialFrameOrigin: CGPoint = .zero
    
    
    init(childViewController: SheetContentNavigationController) {
        self.childViewController = childViewController
        
        passThroughView = PassThroughView()
        sheetView = SheetView(contentView: childViewController.view)
        panGestureRecognizer = UIPanGestureRecognizer()
        
        super.init(nibName: nil, bundle: nil)
        childViewController.sheetNavigationDelegate = self
        
        commonInit()
    }
    
    
    init(childViewController: SheetContentCustomizing) {
        self.childViewController = childViewController
        passThroughView = PassThroughView()
        sheetView = SheetView(contentView: childViewController.view)
        panGestureRecognizer = UIPanGestureRecognizer()
        
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }
    
    
    private func commonInit() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanning(gestureRecognizer:)))
        sheetView.addGestureRecognizer(panGestureRecognizer)
        sheetView.isUserInteractionEnabled = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        addChild(childViewController)
        passThroughView.addSubview(sheetView)
        
        view = passThroughView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
    }
    
    
    private func setUpConstraints() {
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetViewTopConstraint = view.bottomAnchor.constraint(equalTo: sheetView.topAnchor, constant: 0)
        
        NSLayoutConstraint.activate([sheetViewTopConstraint,
                                     sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
    
    
    func addSheet(toParent parentVC: UIViewController) {
        if parent == nil {
            self.view.translatesAutoresizingMaskIntoConstraints = false
            parentVC.addChild(self)
            parentVC.view.addSubview(view)
            view.setUpConstraintsToFitToParent()
            parentVC.view.setNeedsLayout()
            parentVC.view.layoutIfNeeded()
            
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                self.sheetViewTopConstraint.constant = self.childViewController.sheetHeight
                self.view.layoutIfNeeded()
            })
            animator.startAnimation()
            
            didMove(toParent: parentVC)
        }
    }
    
    
    func hide() {
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
            self.sheetViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        animator.addCompletion { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
        animator.startAnimation()
        delegate?.sheetViewController(self, didUpdateSheetHeight: 0)
    }
    
    
    @objc func handlePanning(gestureRecognizer: UIPanGestureRecognizer) {
        guard let sheet = gestureRecognizer.view else {
            return
        }
        // 1. Hide if the view is below the threashold
        // 2. Snap specific point
        
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let translation = gestureRecognizer.translation(in: sheet.superview)
        if gestureRecognizer.state == .began {
            // Save the view's original position.
            self.initialFrameOrigin = sheet.frame.origin
        }
        
        // Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            let newFrameOrigin = CGPoint(x: initialFrameOrigin.x, y: initialFrameOrigin.y + translation.y)
            sheet.frame.origin = newFrameOrigin
            guard let parent = parent else {
                return
            }
            let sheetHeight = parent.view.frame.size.height - newFrameOrigin.y
            delegate?.sheetViewController(self, didUpdateSheetHeight: sheetHeight)
        }
        else {
            // On cancellation, return the piece to its original location.
            sheet.center = initialFrameOrigin
        }
    }
}


extension SheetViewController : SheetContentNavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: SheetContentCustomizing, animated: Bool) {
        // Intentionally empty
    }


    func navigationController(_ navigationController: UINavigationController, didShow viewController: SheetContentCustomizing, animated: Bool) {
        view.layoutIfNeeded()
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.sheetViewTopConstraint.constant = viewController.sheetHeight
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.delegate?.sheetViewController(self, didUpdateSheetHeight: viewController.sheetHeight)
        })
    }
}
