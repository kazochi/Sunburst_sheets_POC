//
//  SheetView.swift
//  Sunburst_sheets_POC
//
//  Created by Kazuhito Ochiai on 11/19/19.
//  Copyright © 2019 Grubhub. All rights reserved.
//

import UIKit

final class SheetView: UIView {
    
    var contentView: UIView
    var grabberView = UIView()
    
    init(contentView: UIView) {
        self.contentView = contentView
        
        super.init(frame: .zero)
        
        grabberView.backgroundColor = .green
        
        addSubview(grabberView)
        addSubview(contentView)
        setUpConstraints()
    }
    
    
    private func setUpConstraints() {
        let grabberViewHeight: CGFloat = 20
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([grabberView.topAnchor.constraint(equalTo: topAnchor),
                                     grabberView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     grabberView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     grabberView.heightAnchor.constraint(equalToConstant: grabberViewHeight)])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalTo: grabberView.bottomAnchor),
                                     contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        heightAnchor.constraint(equalToConstant: 800).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
