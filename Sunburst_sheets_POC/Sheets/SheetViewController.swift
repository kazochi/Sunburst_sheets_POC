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
    private(set) var currentPosition: SheetPosition = .hidden
    let sheetView: SheetView
    var sheetViewTopConstraint: NSLayoutConstraint!
    weak var delegate: SheetViewControllerDelegate?
    private let sheetPanGestureRecognizer: UIPanGestureRecognizer
    private let contentViewController: SheetContentCustomizing
    private let passThroughView: PassThroughView
    private var initialFrameOrigin: CGPoint = .zero
    private var initialContentOffset: CGFloat = 0
    
    init(contentViewController: SheetContentNavigationController) {
        self.contentViewController = contentViewController
        
        passThroughView = PassThroughView()
        sheetView = SheetView(contentView: contentViewController.view)
        sheetPanGestureRecognizer = UIPanGestureRecognizer()
        
        super.init(nibName: nil, bundle: nil)
        contentViewController.sheetNavigationDelegate = self
        
        commonInit()
    }
    
    
    init(contentViewController: SheetContentCustomizing) {
        self.contentViewController = contentViewController
        passThroughView = PassThroughView()
        sheetView = SheetView(contentView: contentViewController.view)
        sheetPanGestureRecognizer = UIPanGestureRecognizer()
        
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }
    
    
    private func commonInit() {
        sheetPanGestureRecognizer.addTarget(self, action: #selector(handlePanning(gestureRecognizer:)))
        sheetView.addGestureRecognizer(sheetPanGestureRecognizer)
        sheetView.isUserInteractionEnabled = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        addChild(contentViewController)
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
            self.view.translatesAutoresizingMaskIntoConstraints = false
            parentVC.addChild(self)
            parentVC.view.addSubview(view)
            view.setUpConstraintsToFitToParent()
            parentVC.view.setNeedsLayout()
            parentVC.view.layoutIfNeeded()
            
            self.currentPosition = contentViewController.sheetBehavior.initialPosition
            
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                               delay: 0,
                                                               options: .curveEaseInOut,
                                                               animations: {
                                                                self.sheetViewTopConstraint.constant = self.contentViewController.sheetBehavior.topInset(for: self.currentPosition, relativeTo: self.view)
                                                                self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.didMove(toParent: parentVC)
                    completion?()
                })
            } else {
                self.sheetViewTopConstraint.constant = contentViewController.sheetBehavior.topInset(for: self.currentPosition, relativeTo: self.view)
                self.view.layoutIfNeeded()
                self.didMove(toParent: parentVC)
                completion?()
            }
        }
    }
    
    
    func removeFromParent(animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                           delay: 0,
                                                           options: .curveEaseInOut,
                                                           animations: {
                                                            self.sheetViewTopConstraint.constant = 0
                                                            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.delegate?.sheetViewController(self, didUpdateSheetHeight: 0)
                completion?()
            })
        } else {
            self.sheetViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.delegate?.sheetViewController(self, didUpdateSheetHeight: 0)
            completion?()
        }
    }
    
    
    func update(sheetHeight: CGFloat, completion: (() -> Void)? = nil) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                       delay: 0,
                                                       options: .curveEaseInOut,
                                                       animations: {
                                                        self.sheetViewTopConstraint.constant = sheetHeight
                                                        self.view.layoutIfNeeded()
        }, completion: { _ in
            self.delegate?.sheetViewController(self, didUpdateSheetHeight: sheetHeight)
            completion?()
        })
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
                    delegate?.sheetViewController(self, didUpdateSheetHeight: sheetHeight)
                }
                else {
                    // On cancellation, return the piece to its original location.
                    sheet.frame.origin = initialFrameOrigin
                }
            }
        }
        else {
            // 1. Hide if the view is below the threashold
            // 2. Snap specific point
            
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
                    let snapFrameOrigin = calculateSnapPoint(for: newFrameOrigin, velocity: velocity)
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                                   delay: 0,
                                                                   options: .curveEaseInOut,
                                                                   animations: {
                                                                    //                                                                    self.sheetViewTopConstraint.constant = self.contentViewController.sheetHeight
                                                                    sheet.frame.origin = snapFrameOrigin
                                                                    
                    })
                } else {
                    sheet.frame.origin = newFrameOrigin
                }
                guard let parent = parent else {
                    return
                }
                let sheetHeight = parent.view.frame.size.height - newFrameOrigin.y
                delegate?.sheetViewController(self, didUpdateSheetHeight: sheetHeight)
            }
            else {
                // On cancellation, return the piece to its original location.
                sheet.frame.origin = initialFrameOrigin
            }
        }
    }
    
    
    
    /// Calculate correct snappoint based on current view origin and velocity of the pan gesture
    ///
    /// - Parameters:
    ///   - origin: <#origin description#>
    ///   - translation: <#translation description#>
    /// - Returns: <#return value description#>
    func calculateSnapPoint(for origin: CGPoint, velocity: CGPoint) -> CGPoint {
        let velocityY = velocity.y

        if abs(velocityY) > 300 {
            let isPannedUp = velocityY < 0
            
            if isPannedUp {
                currentPosition = currentPosition.next ?? .full
            } else {
                currentPosition = currentPosition.previous ?? .hidden
            }
        } else {
            // get SheetPosition based given current origin
            currentPosition = contentViewController.sheetBehavior.position(for: origin, in: view)
        }
        let snapPointY = contentViewController.sheetBehavior.topInset(for: currentPosition, relativeTo: view)
        
        print("originY is \(origin.y), currentPosition: \(currentPosition), snapY: \(snapPointY)")
        
        return CGPoint(x: origin.x, y: snapPointY)
    }
}



extension SheetViewController : SheetContentNavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: SheetContentCustomizing, animated: Bool) {
        // Intentionally empty
    }


    func navigationController(_ navigationController: UINavigationController, didShow viewController: SheetContentCustomizing, animated: Bool) {
        view.layoutIfNeeded()
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.sheetViewTopConstraint.constant = viewController.sheetBehavior.topInset(for: self.currentPosition, relativeTo: self.view)
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.delegate?.sheetViewController(self, didUpdateSheetHeight: self.sheetViewTopConstraint.constant)
        })
    }
}
