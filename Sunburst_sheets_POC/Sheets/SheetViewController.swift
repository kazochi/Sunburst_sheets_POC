//
//  SheetViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/19/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

protocol SheetViewContent {
    
}


enum SheetPosition : Int {
    case full, partialMax, partialDefault, Collapsed, hidden
}

final class SheetViewController : UIViewController, SheetContentNavigationControllerDelegate {
    let position: SheetPosition = .hidden
    let sheetView: SheetView
    var sheetViewTopConstraint: NSLayoutConstraint!
    
    private let childViewController: UIViewController
    private let passThroughView: PassThroughView
    
    
    init(childViewController: SheetContentNavigationController) {
        self.childViewController = childViewController
        passThroughView = PassThroughView()
        sheetView = SheetView(contentView: childViewController.view)
        
        super.init(nibName: nil, bundle: nil)
        childViewController.sheetNavigationDelegate = self
    }
    
    init(childViewController: UIViewController) {
        self.childViewController = childViewController
        
        passThroughView = PassThroughView()
        sheetView = SheetView(contentView: childViewController.view)

        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        // Set childViewController's view to sheet's content
        
        // Add the sheet view to the passThroughView
        addChild(childViewController)
        passThroughView.addSubview(sheetView)

        view = passThroughView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
        sheetView.backgroundColor = .blue
    }
    
    
    private func setUpConstraints() {
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetViewTopConstraint = sheetView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([sheetViewTopConstraint,
                                     sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func addSheet(toParent parent: UIViewController) {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(self)
        parent.view.addSubview(view)
        view.setUpConstraintsToFitToParent()
        parent.view.setNeedsLayout()
        parent.view.layoutIfNeeded()

        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
            self.sheetViewTopConstraint.constant = -300
            self.view.layoutIfNeeded()
        })
        animator.startAnimation()
        
        didMove(toParent: parent)
    }
    
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: SheetContentCustomizing, animated: Bool) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
            self.sheetViewTopConstraint.constant = -viewController.sheetHeight
            self.view.layoutIfNeeded()
        })
        animator.startAnimation()
    }
}


extension UIView {
    func setUpConstraintsToFitToParent() {
        guard let superView = superview else {
            return
        }
        NSLayoutConstraint.activate([topAnchor.constraint(equalTo: superView.topAnchor),
                                     bottomAnchor.constraint(equalTo: superView.bottomAnchor),
                                     leadingAnchor.constraint(equalTo: superView.leadingAnchor),
                                     trailingAnchor.constraint(equalTo: superView.trailingAnchor)])
    }
}


final class PassThroughView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
