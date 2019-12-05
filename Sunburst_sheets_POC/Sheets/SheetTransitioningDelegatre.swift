//
//  SheetTransitioningDelegatre.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 12/4/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class SheetActionSheetTransitioningDelegate :NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SheetModalPresentTransition()
        
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SheetModalDismissTransition()
    }
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


class SheetPresentationController: UIPresentationController {
    private let dimmingView = UIView()
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = self.containerView,
            let sheetController = presentedViewController as? SheetController else {
                fatalError()
        }
        sheetController.sheetPanGestureRecognizer.isEnabled = false
        
        // Setting up the dimming view
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0.0
        let tapToDismissGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(tapGesture:)))
        dimmingView.addGestureRecognizer(tapToDismissGestureRecognizer)
        containerView.addSubview(dimmingView)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.setUpConstraintsToFitToParent()
        
        // Adding the sheet
        sheetController.view.translatesAutoresizingMaskIntoConstraints = false
        sheetController.sheetView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sheetController.view)
        sheetController.view.setUpConstraintsToFitToParent()
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        
        NSLayoutConstraint.activate([sheetController.sheetView.leadingAnchor.constraint(equalTo: sheetController.view.leadingAnchor),
                                     sheetController.sheetView.trailingAnchor.constraint(equalTo: sheetController.view.trailingAnchor)])
        
        sheetController.sheetViewTopConstraint = sheetController.sheetView.topAnchor.constraint(equalTo: sheetController.view.safeAreaLayoutGuide.topAnchor, constant: containerView.bounds.size.height)
        sheetController.sheetViewTopConstraint.isActive = true
        
        sheetController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.4
        })
    }
    
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
    
    
    @objc func handleDismissTap(tapGesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if let sheetController = presentedViewController as? SheetController {
            if let containerView = self.containerView {
                sheetController.sheetViewTopConstraint.constant = containerView.bounds.size.height
            }
            sheetController.view.removeFromSuperview()
        }
    }
}


class SheetModalPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(0.2)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sheetController = transitionContext.viewController(forKey: .to) as? SheetController else {
            fatalError()
        }
        sheetController.sheetViewTopConstraint.constant = transitionContext.containerView.bounds.size.height
        transitionContext.containerView.setNeedsLayout()
        transitionContext.containerView.layoutIfNeeded()
        
        let snapAimator: UIViewPropertyAnimator
        if case let .panAndSnap(configuration) = sheetController.contentViewController.sheetBehavior, let animator = configuration.snapAnimator {
            snapAimator = animator
            snapAimator.addAnimations {
                sheetController.sheetViewTopConstraint.constant = sheetController.topInset(for: configuration.initialPosition)
                sheetController.view.layoutIfNeeded()
            }
        } else {
            snapAimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: nil)
            snapAimator.addAnimations {
                sheetController.sheetViewTopConstraint.constant = sheetController.topInset(for: .full)
                sheetController.view.layoutIfNeeded()
            }
        }
        
        snapAimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        snapAimator.startAnimation()
    }
}


class SheetModalDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(0.2)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sheetController = transitionContext.viewController(forKey: .from) as? SheetController else {
            fatalError()
        }
        let snapAimator: UIViewPropertyAnimator
        if case let .panAndSnap(configuration) = sheetController.contentViewController.sheetBehavior, let animator = configuration.snapAnimator {
            snapAimator = animator
            snapAimator.addAnimations {
                sheetController.sheetViewTopConstraint.constant = transitionContext.containerView.bounds.size.height
                sheetController.view.layoutIfNeeded()
            }
        } else {
            snapAimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: nil)
            snapAimator.addAnimations {
                sheetController.sheetViewTopConstraint.constant = transitionContext.containerView.bounds.size.height
                sheetController.view.layoutIfNeeded()
            }
        }
        
        snapAimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        snapAimator.startAnimation()
    }
}
