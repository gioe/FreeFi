//
//  PermissionView.swift
//  FreeFi
//
//  Created by Matt on 12/8/17.
//  Copyright © 2017 Matt. All rights reserved.
//

import UIKit

class PermissionView: UIView {

    private let topLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Whoops! It looks like you've denied access to your device's location."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "FreeFi requires location access in order to find free local WiFi spots for you. Please click the link below and enable access to Location in your phone's settings"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let submissionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Device Permissions", for: .normal)
        button.setTitleColor(ColorConstant.yellow.color, for: .normal)
        button.addTarget(self, action: #selector(navigateToPermissions), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        configureView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        [topLabel, descriptionLabel, submissionButton].forEach{
            addSubview($0)
        }
    }
    
    override func layoutSubviews() {
        topLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        topLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        topLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
        topLabel.sizeToFit()

        descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 10).isActive = true
        descriptionLabel.sizeToFit()
        
        submissionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10).isActive = true
        submissionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        submissionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submissionButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
    
    @objc private func navigateToPermissions() {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

}
