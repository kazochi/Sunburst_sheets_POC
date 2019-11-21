//
//  UIView+AutoLayout.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/21/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

extension UIView {
    func setUpConstraintsToFitToParent() {
        guard let superView = superview else {
            return
        }
        NSLayoutConstraint.activate([topAnchor.constraint(equalTo: superView.topAnchor),
                                     bottomAnchor.constraint(equalTo: superView.bottomAnchor),
                                     leadingAnchor.constraint(equalTo: superView.leadingAnchor),
                                     trailingAnchor.constraint(equalTo: superView.trailingAnchor)])
    }
}
