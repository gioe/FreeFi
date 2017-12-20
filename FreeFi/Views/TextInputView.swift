//
//  TextInputView.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/6/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import TextFieldEffects

class TextInputView: UIView {
    
    public var isEmpty: Bool {
        guard let textInputText = textInput.text, !textInputText.isEmpty else {
            return true
        }
        return false
    }
    
    var textInput: HoshiTextField = {
        var input = HoshiTextField()
        input.borderActiveColor = .white
        input.borderInactiveColor = .black
        input.textAlignment = .left
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        
        [textInput].forEach{
            addSubview($0)
        }
    }
    
    override func layoutSubviews() {
        textInput.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        textInput.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        textInput.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        textInput.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
    }
    
}
