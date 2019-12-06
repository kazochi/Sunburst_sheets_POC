//
//  SheetContentViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 12/5/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class SheetContentViewController: UIViewController, SheetContentCustomizing {
    @IBOutlet private var coloredViews: [UIView] = []

    let sheetBehavior: SheetBehavior
    
    init(sheetBehavior: SheetBehavior) {
        self.sheetBehavior = sheetBehavior
        super.init(nibName: nil, bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        for view in coloredViews {
            view.layer.cornerRadius = 5
        }
    }
}
