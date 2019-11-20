//
//  ModalViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/18/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class ModalViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion:nil)
    }
}


class CustomPresentationController : UIPresentationController {
    
    override func presentationTransitionWillBegin() {
        
    }
}
