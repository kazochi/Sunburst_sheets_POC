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
    var grabberContainerView = UIView()
    private let grabberView = GrabberView()
    
    init(contentView: UIView) {
        self.contentView = contentView
        
        super.init(frame: .zero)

        grabberContainerView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        grabberContainerView.addSubview(grabberView)
        
        addSubview(grabberContainerView)
        addSubview(contentView)
        setUpConstraints()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    
    private func setUpConstraints() {
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        let grabberWidth: CGFloat = 20
        let grabberHeight: CGFloat = 5
        NSLayoutConstraint.activate([grabberView.centerYAnchor.constraint(equalTo: grabberContainerView.centerYAnchor),
                                     grabberView.centerXAnchor.constraint(equalTo: grabberContainerView.centerXAnchor),
                                     grabberView.widthAnchor.constraint(equalToConstant: grabberWidth),
                                     grabberView.heightAnchor.constraint(equalToConstant: grabberHeight)])
        
        
        let grabberContainerViewHeight: CGFloat = 20
        grabberContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([grabberContainerView.topAnchor.constraint(equalTo: topAnchor),
                                     grabberContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     grabberContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     grabberContainerView.heightAnchor.constraint(equalToConstant: grabberContainerViewHeight)])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalTo: grabberContainerView.bottomAnchor),
                                     contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        heightAnchor.constraint(equalToConstant: contentView.bounds.size.height).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
