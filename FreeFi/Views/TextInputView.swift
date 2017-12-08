//
//  TextInputView.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/6/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit

class TextInputView: UIView {
    
    var textInput: UITextField = {
        var input = UITextField()
        input.textAlignment = .right
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    public var textLabel: UILabel = {
        var label = UILabel()
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
        
        [textInput, textLabel].forEach{
            addSubview($0)
        }
    }
    
    override func layoutSubviews() {
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        textLabel.widthAnchor.constraint(equalToConstant: bounds.width / 2).isActive = true
        
        textInput.leftAnchor.constraint(equalTo: textLabel.rightAnchor).isActive = true
        textInput.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        textInput.heightAnchor.constraint(equalTo: textLabel.heightAnchor).isActive = true
        textInput.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor).isActive = true
    }
    
}
