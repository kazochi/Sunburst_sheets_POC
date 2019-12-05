//
//  SheetController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/19/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

protocol SheetViewControllerDelegate: AnyObject {
    func sheetViewController(_ sheetViewController: SheetController, didUpdateSheetHeight sheetHeight: CGFloat, sheetPosition: SheetPosition)
}


final class SheetController : UIViewController {
    private(set) var currentPosition: SheetPosition = .offScreen
    let sheetView: SheetView
    var sheetViewTopConstraint: NSLayoutConstraint!
    weak var delegate: SheetViewControllerDelegate?
    let sheetPanGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    let contentViewController: SheetContentCustomizing
    private let passThroughView: PassThroughView = PassThroughView()
    private var initialFrameOrigin: CGPoint = .zero
    private var initialContentOffset: CGFloat = 0
    private let actionSheetTransitioningDelegate = SheetActionSheetTransitioningDelegate()
    
    init(contentViewController: SheetContentCustomizing) {
        self.contentViewController = contentViewController
        sheetView = SheetView(contentView: contentViewController.view)
        
        super.init(nibName: nil, bundle: nil)

        commonInit()
    }
    
    
    private func commonInit() {
        if let contentNavigationController = contentViewController as? SheetContentNavigationController {
            contentNavigationController.sheetNavigationDelegate = self
        }
        
        sheetPanGestureRecognizer.addTarget(self, action: #selector(handlePanning(gestureRecognizer:)))
        sheetView.addGestureRecognizer(sheetPanGestureRecognizer)
        sheetView.isUserInteractionEnabled = true
        transitioningDelegate = actionSheetTransitioningDelegate
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        addChild(contentViewController)
        passThroughView.addSubview(sheetView)
        
        view = passThroughView
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
//    private func setUpConstraints() {
//        sheetView.translatesAutoresizingMaskIntoConstraints = false
//        sheetViewTopConstraint = sheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
//
//        NSLayoutConstraint.activate([sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                                     sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
//    }
    
    private (set) var trackedScrollView: UIScrollView?
    
    func track(scrollView: UIScrollView) {
        trackedScrollView = scrollView
        trackedScrollView?.panGestureRecognizer.addTarget(self, action: #selector(handlePanning(gestureRecognizer:)))
    }
    
    func untrackScrollView() {
        trackedScrollView?.panGestureRecognizer.removeTarget(self, action: #selector(handlePanning(gestureRecognizer:)))
        trackedScrollView = nil
    }
    
    
    func add(toParent parentVC: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        if parent == nil {
            view.translatesAutoresizingMaskIntoConstraints = false
            parentVC.addChild(self)
            parentVC.view.addSubview(view)
            view.setUpConstraintsToFitToParent()

            parentVC.view.setNeedsLayout()
            parentVC.view.layoutIfNeeded()
            
            sheetView.translatesAutoresizingMaskIntoConstraints = false
            sheetViewTopConstraint = sheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.size.height)

            NSLayoutConstraint.activate([sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                         sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
            
            sheetViewTopConstraint.isActive = true
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            switch contentViewController.sheetBehavior {
            case let .panAndSnap(configuration):
                self.currentPosition = configuration.initialPosition
            case .fullOrDismissed:
                self.currentPosition = .full
            case .fixedHeight:
                self.currentPosition = .partialDefault
            }
            
            if animated {
                let snapAimator: UIViewPropertyAnimator
                if case let .panAndSnap(configuration) = contentViewController.sheetBehavior, let animator = configuration.snapAnimator {
                    snapAimator = animator
                } else {
                    snapAimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: nil)
                }
                
                snapAimator.addAnimations {
                    self.sheetViewTopConstraint.constant = self.topInset(for: self.currentPosition)
                    self.view.layoutIfNeeded()
                }
                
                snapAimator.addCompletion { _ in
                    self.didMove(toParent: parentVC)
                    completion?()
                }
                snapAimator.startAnimation()
                
            } else {
                self.sheetViewTopConstraint.constant = self.topInset(for: self.currentPosition)
                self.view.layoutIfNeeded()
                self.didMove(toParent: parentVC)
                completion?()
            }
        }
    }
    
    func topInset(for position: SheetPosition) -> CGFloat {
        switch contentViewController.sheetBehavior {
        case let .panAndSnap(sheetPositionConfiguration):
            switch position {
            case .full:
                return sheetPositionConfiguration.full?.topInset ?? 0
            case .partialMax:
                return sheetPositionConfiguration.partialMax!.topInset!
            case .partialDefault:
                return sheetPositionConfiguration.partialDefault!.topInset!
            case .offScreen:
                return sheetPositionConfiguration.offScreen?.topInset ?? view.bounds.size.height
            }
        case .fullOrDismissed:
            switch position {
            case .offScreen:
                return view.bounds.size.height
            case .full, .partialMax, .partialDefault:
                return 0
            }
        case let .fixedHeight(height):
            return height
        }
    }
    
    
    func removeFromParent(animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                           delay: 0,
                                                           options: .curveEaseInOut,
                                                           animations: {
                                                            self.sheetViewTopConstraint.constant = self.view.bounds.height
                                                            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.view.removeFromSuperview()
                self.removeFromParent()
                completion?()
            })
        } else {
            self.sheetViewTopConstraint.constant = self.view.bounds.height
            self.view.layoutIfNeeded()
            self.view.removeFromSuperview()
            self.removeFromParent()
            completion?()
        }
    }
    
    
    func update(sheetHeight: CGFloat, completion: (() -> Void)? = nil) {
        let snapAimator: UIViewPropertyAnimator
        if case let .panAndSnap(configuration) = contentViewController.sheetBehavior, let animator = configuration.snapAnimator {
            snapAimator = animator
        } else {
            snapAimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: nil)
        }
        snapAimator.addAnimations {
            self.sheetViewTopConstraint.constant = sheetHeight
            self.view.layoutIfNeeded()
        }
        
        snapAimator.addCompletion { _ in
            self.delegate?.sheetViewController(self, didUpdateSheetHeight: sheetHeight, sheetPosition: self.currentPosition)
            completion?()
        }
        
        snapAimator.startAnimation()
    }
    
    private func printGestureState(gestureRecognizer: UIGestureRecognizer) {
        var str = ""
        switch(gestureRecognizer.state) {
        case .possible:
            str = "possible"
        case .began:
            str = "begin"
        case .changed:
            str = "changed"
        case .ended:
            str = "ended"
        case .cancelled:
            str = "cancelled"
        case .failed:
            str = "failed"
        @unknown default:
            str = "Unknown"
        }
        print(str)
    }
    
    
    @objc private func handlePanning(gestureRecognizer: UIPanGestureRecognizer) {
       print("velocity \(gestureRecognizer.velocity(in: view))")
       printGestureState(gestureRecognizer: gestureRecognizer)
        
        guard let sheet = sheetPanGestureRecognizer.view else {
            return
        }
        
        if gestureRecognizer.state == .began {
            initialFrameOrigin = sheet.frame.origin
            if let scrollView = gestureRecognizer.view as? UIScrollView {
                initialContentOffset = scrollView.contentOffset.y > 0 ? scrollView.contentOffset.y : 0
                print(initialContentOffset)
            }
        }
        
        // If gesture recognizer is from the trackedScrollView
        if gestureRecognizer == trackedScrollView?.panGestureRecognizer {
            guard let scrollView = gestureRecognizer.view as? UIScrollView else {
                return
            }
            var scrollViewTranslation = gestureRecognizer.translation(in: scrollView.superview)
            scrollViewTranslation.y -= initialContentOffset

            if scrollViewTranslation.y > 0 && scrollView.contentOffset.y <= 0 {
                trackedScrollView?.bounces = false
                
                // Update the position for the .began, .changed, and .ended states
                if sheetPanGestureRecognizer.state != .cancelled {
                    // Add the X and Y translation to the view's original position.
                    let newFrameOrigin = CGPoint(x: initialFrameOrigin.x, y: initialFrameOrigin.y + scrollViewTranslation.y)
                    print("initial origin: \(initialFrameOrigin.y), translation: \(scrollViewTranslation.y), newFrameY: \(newFrameOrigin.y)")
                    sheet.frame.origin = newFrameOrigin
                    guard let parent = parent else {
                        return
                    }
                    let sheetHeight = parent.view.frame.size.height - newFrameOrigin.y
                    delegate?.sheetViewController(self, didUpdateSheetHeight: sheetHeight, sheetPosition: self.currentPosition)
                }
                else {
                    // On cancellation, return the piece to its original location.
                    sheet.frame.origin = initialFrameOrigin
                }
            }
        }
        else {
            // Get the changes in the X and Y directions relative to
            // the superview's coordinate space.
            let translation = sheetPanGestureRecognizer.translation(in: sheet.superview)
            
            // Update the position for the .began, .changed, and .ended states
            if sheetPanGestureRecognizer.state != .cancelled {
                // Add the X and Y translation to the view's original position.
                let newFrameOrigin = CGPoint(x: initialFrameOrigin.x, y: initialFrameOrigin.y + translation.y)
                print("initial origin: \(initialFrameOrigin.y), translation: \(translation.y), newFrameY: \(newFrameOrigin.y)")
                
                // snapping
                if sheetPanGestureRecognizer.state == .ended {
                    let velocity = gestureRecognizer.velocity(in: view)
                    
                    if case .fullOrDismissed = contentViewController.sheetBehavior, abs(velocity.y) > 300 {
                        delegate?.sheetViewController(self, didUpdateSheetHeight: 0, sheetPosition: .offScreen)
                        removeFromParent(animated: true)
                        return
                    }
                    
                    let snapAimator: UIViewPropertyAnimator
                    if case let .panAndSnap(configuration) = contentViewController.sheetBehavior, let animator = configuration.snapAnimator {
                        snapAimator = animator
                    } else {
                        snapAimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: nil)
                    }
                  
                    let snapFrameOrigin = calculateSnapPoint(for: newFrameOrigin, velocity: velocity)
                    
                    snapAimator.addAnimations {
                        if case .fullOrDismissed = self.contentViewController.sheetBehavior {
                            self.delegate?.sheetViewController(self, didUpdateSheetHeight: 0, sheetPosition: .offScreen)
                            self.removeFromParent(animated: true)
                            return
                        }
                        self.sheetViewTopConstraint.constant = snapFrameOrigin.y
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        
                    }
                    
                    snapAimator.addCompletion { _ in
                        self.delegate?.sheetViewController(self, didUpdateSheetHeight: snapFrameOrigin.y, sheetPosition: self.currentPosition)
                    }
                    
                    snapAimator.startAnimation()
                } else {
                    sheet.frame.origin = newFrameOrigin
                }
            }
            else {
                // On cancellation, return the piece to its original location.
                sheet.frame.origin = initialFrameOrigin
            }
        }
    }
    
    
    
    /// Calculate correct snappoint based on current view origin and velocity of the pan gesture
    func calculateSnapPoint(for origin: CGPoint, velocity: CGPoint) -> CGPoint {
        let velocityY = velocity.y

        // If user swipes rather than panning, set the position to next or previous depends on the direction of the panning
        if abs(velocityY) > 300 {
            switch contentViewController.sheetBehavior {
            case .panAndSnap:
                let direction: SheetPositionDirection = (velocityY < 0) ? .up : .down
                currentPosition = contentViewController.sheetBehavior.nextSupportedPosition(from: currentPosition, direction: direction)
            case .fullOrDismissed:
                currentPosition = .offScreen
            case .fixedHeight:
                currentPosition = .partialDefault
            }
        } else {
            // get SheetPosition based given current origin
            currentPosition = contentViewController.sheetBehavior.sheetPosition(for: origin, parentView: view)
        }
        let snapPointY = topInset(for: currentPosition)
        
        print("originY is \(origin.y), currentPosition: \(currentPosition), snapY: \(snapPointY)")
        
        return CGPoint(x: origin.x, y: snapPointY)
    }
}



extension SheetController : SheetContentNavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: SheetContentCustomizing, animated: Bool) {
        // Intentionally empty
    }


    func navigationController(_ navigationController: UINavigationController, didShow viewController: SheetContentCustomizing, animated: Bool) {
        view.layoutIfNeeded()
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//            self.sheetViewTopConstraint.constant = self.topInset(for: self.currentPosition)
//            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.delegate?.sheetViewController(self, didUpdateSheetHeight: self.sheetViewTopConstraint.constant, sheetPosition: self.currentPosition)
        })
    }
}
