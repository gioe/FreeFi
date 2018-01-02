//
//  DoubleTextInputView.swift
//  FreeFi
//
//  Created by Matt on 12/18/17.
//  Copyright © 2017 Matt. All rights reserved.
//

import UIKit
import TextFieldEffects

public class DoubleTextInputView: UIView {
    
    public var isEmpty: Bool {
        guard let networkName = cityInput.text, !networkName.isEmpty, let passwordName = stateInput.text, !passwordName.isEmpty else {
            return true
        }
        return false
    }
    
    var cityInput: HoshiTextField = {
        var input = HoshiTextField()
        input.borderActiveColor = .white
        input.borderInactiveColor = .black
        input.adjustsFontSizeToFitWidth = true
        input.minimumFontSize = 7.0
        input.placeholder = "City"
        input.textAlignment = .left
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    var stateInput: HoshiTextField = {
        var input = HoshiTextField()
        input.borderActiveColor = .white
        input.borderInactiveColor = .black
        input.adjustsFontSizeToFitWidth = true
        input.minimumFontSize = 7.0
        input.placeholder = "State"
        input.textAlignment = .left
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        
        [cityInput, stateInput].forEach{
            addSubview($0)
        }
        
    }
    
    override public func layoutSubviews() {
        cityInput.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        cityInput.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        cityInput.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        cityInput.widthAnchor.constraint(equalToConstant: (bounds.width / 2) - 10).isActive = true
        
        stateInput.leftAnchor.constraint(equalTo: cityInput.rightAnchor, constant:20).isActive = true
        stateInput.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        stateInput.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        stateInput.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
    }
        
}
