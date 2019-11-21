//
//  DemoTableViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/19/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class DemoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var sheetViewController: SheetViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cookbook Sheet Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoTableViewControllerCell")
        
        let childContentViewController = BackgroundColorScrollViewController()
        
        let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
        sheetViewController = SheetViewController(childViewController: navigationController)
        sheetViewController?.loadViewIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoTableViewControllerCell")!
        
        cell.textLabel?.text = "Toggle sheet"
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
