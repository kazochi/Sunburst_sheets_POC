//
//  DemoTableViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/19/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class DemoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var sheetViewController: SheetViewController!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cookbook Sheet Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoTableViewControllerCell")
        
        let childContentViewController = BackgroundColorScrollViewController()
        
        let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
        sheetViewController = SheetViewController(childViewController: navigationController)
        sheetViewController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoTableViewControllerCell")!
        if indexPath.row == 0 {
            cell.textLabel?.text = "Toggle sheet"
        } else {
            cell.textLabel?.text = "\(indexPath.row)"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sheetViewController?.parent == nil {
            sheetViewController?.addSheet(toParent: self)
        } else {
            sheetViewController?.hide()
        }
        tableView.reloadData()
    }
}


extension DemoTableViewController : SheetViewControllerDelegate {
    func sheetViewController(_ sheetViewController: SheetViewController, didUpdateSheetHeight sheetHeight: CGFloat) {
        let contentInsetBottom = sheetHeight - view.safeAreaInsets.bottom
        tableView.contentInset.bottom = contentInsetBottom
        tableView.scrollIndicatorInsets.bottom = contentInsetBottom
    }
}
