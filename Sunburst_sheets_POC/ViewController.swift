//
//  ViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/18/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonPressed() {
        let mvc = ModalViewController()
        let nav = UINavigationController(rootViewController: mvc)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        present(nav, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

