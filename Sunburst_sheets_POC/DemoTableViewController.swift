//
//  DemoTableViewController.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/19/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

class DemoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var sheetViewController: SheetController!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cookbook Sheet Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoTableViewControllerCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoTableViewControllerCell")!
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Toggle sheet (Full or dismiss)"
        case 1:
            cell.textLabel?.text = "Toggle table view sheet (Snap)"
        case 2:
            cell.textLabel?.text = "set sheet height to 500"
        case 3:
            cell.textLabel?.text = "Action sheet"
        default:
            cell.textLabel?.text = "\(indexPath.row)"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if sheetViewController?.parent == nil {
                let childContentViewController = BackgroundColorScrollViewController()
                
                let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
                sheetViewController = SheetController(contentViewController: navigationController)
                sheetViewController.delegate = self
                sheetViewController?.add(toParent: self, animated: true)
                sheetViewController.track(scrollView: childContentViewController.scrollView)
            } else {
                sheetViewController?.removeFromParent(animated: true)
            }
        case 1:
            if sheetViewController?.parent == nil {
                let childContentViewController = SheetContentTableTableViewController()
                
                let navigationController = SheetContentNavigationController(rootViewController: childContentViewController)
                sheetViewController = SheetController(contentViewController: navigationController)
                sheetViewController.delegate = self
                sheetViewController?.add(toParent: self, animated: true)
                sheetViewController.track(scrollView: childContentViewController.tableView)
            } else {
                sheetViewController?.removeFromParent(animated: true)
            }
        case 2:
            if sheetViewController?.parent != nil {
                sheetViewController.update(sheetHeight: 500)
            }
        case 3:
            let childContentViewController = SheetContentTableTableViewController()
            let sheetViewController = SheetController(contentViewController: childContentViewController)
            sheetViewController.modalPresentationStyle = .custom
            present(sheetViewController, animated: true, completion: nil)
        default:
            ()
        }
    }
}


extension DemoTableViewController : SheetViewControllerDelegate {
    func sheetViewController(_ sheetViewController: SheetController, didUpdateSheetHeight sheetHeight: CGFloat, sheetPosition: SheetPosition) {
        let contentInsetBottom = sheetHeight - view.safeAreaInsets.bottom
        tableView.contentInset.bottom = contentInsetBottom
        tableView.scrollIndicatorInsets.bottom = contentInsetBottom
        
        let hideNavigationBar = (sheetPosition == .full || sheetPosition == .partialMax)
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: true)
        title = sheetPosition.description
    }
}
