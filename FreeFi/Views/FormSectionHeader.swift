//
//  FormSectionHeader.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/27/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit

class FormSectionHeader: UIView {
    
    public var textLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        
        backgroundColor = .lightGray
        
        [textLabel].forEach{
            addSubview($0)
        }
    }
    
    override func layoutSubviews() {
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        textLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}

