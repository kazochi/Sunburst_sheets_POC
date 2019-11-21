//
//  BackgroundColorScrollViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class BackgroundColorScrollViewController: UIViewController, SheetContentCustomizing {
    
    var sheetHeight: CGFloat = CGFloat(Int.random(in: 300...800))
    var backgroundColor: UIColor = [UIColor.red, UIColor.black, UIColor.blue, UIColor.green, UIColor.orange, UIColor.white].randomElement()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "sheet height: \(sheetHeight)"
    }
    
    @IBAction func push() {
        let vc = BackgroundColorScrollViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
