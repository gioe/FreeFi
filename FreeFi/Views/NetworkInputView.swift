//
//  NetworkInputView.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/15/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit

protocol AddRowDelegate {
    func addNewRow()
}

class NetworkInputView: UIView {
    
    var addDelegate: AddRowDelegate?
    
    public var isEmpty: Bool {
        guard let networkName = networkNameInput.text, !networkName.isEmpty, let passwordName = passwordInput.text, !passwordName.isEmpty else {
            return true
        }
        return false
    }
    
    var networkNameInput: UITextField = {
        var input = UITextField()
        input.textAlignment = .left
        input.placeholder = "Enter Name"
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    var passwordInput: UITextField = {
        var input = UITextField()
        input.textAlignment = .left
        input.placeholder = "Enter Password"
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    var addButton: UIButton = {
        var button = UIButton()
        button.setBackgroundImage(UIImage(named: "plus"), for: .normal)
        button.addTarget(self, action: #selector(addNetwork), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        
        [networkNameInput, passwordInput, addButton].forEach{
            addSubview($0)
        }
    }
    
    override func layoutSubviews() {
        addButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        addButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        networkNameInput.leftAnchor.constraint(equalTo: addButton.rightAnchor, constant: 10).isActive = true
        networkNameInput.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        networkNameInput.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        networkNameInput.widthAnchor.constraint(equalToConstant: (bounds.width / 2) - 50).isActive = true
        
        passwordInput.leftAnchor.constraint(equalTo: networkNameInput.rightAnchor).isActive = true
        passwordInput.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        passwordInput.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        passwordInput.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        passwordInput.centerYAnchor.constraint(equalTo: networkNameInput.centerYAnchor).isActive = true
        
    }
    
    public func setData(network: Network) {
        networkNameInput.text = network.name
        passwordInput.text = network.password
    }
    
    @objc func addNetwork() {
        addDelegate?.addNewRow()
    }

}

