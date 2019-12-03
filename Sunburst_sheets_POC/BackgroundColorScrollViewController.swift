//
//  BackgroundColorScrollViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

final class BackgroundColorScrollViewController: UIViewController, SheetContentCustomizing {
    let sheetBehavior: SheetBehavior = ScrollAndSnapSheetBehavior.makePartialMaxScrollAndSnapBehavior()

    @IBOutlet var colorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
