//
//  BackgroundColorScrollViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

final class BackgroundColorScrollViewController: UIViewController, SheetContentCustomizing {
    let sheetHeight: CGFloat = CGFloat(Int.random(in: 300...800))
    @IBOutlet var colorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sheet Height \(sheetHeight)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backgroundColors: [UIColor] = [.red, .blue, .green, .orange, .yellow, .purple]        
        colorView.backgroundColor = backgroundColors[navigationController!.viewControllers.count % backgroundColors.count]
    }
    
    
    @IBAction func push() {
        let vc = BackgroundColorScrollViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
