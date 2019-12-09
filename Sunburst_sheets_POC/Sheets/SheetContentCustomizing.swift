//
//  SheetContentCustomizing.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

public protocol SheetContentCustomizing : UIViewController {
    var sheetBehavior: SheetBehavior { get }
}
