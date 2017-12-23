//
//  LoginViewController.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/1/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let appIcon: UIImageView = {
        let imageView = UIImageView()
        let wifiImage = UIImage(named: "wifi")
        imageView.image = wifiImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let signupButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Sign Up", for: .normal)
        
        let orange = UIColor(red: 234, green: 91, blue: 0, alpha: 1)
        button.setTitleColor(orange, for: .normal)
        
        button.addTarget(self, action: #selector(signup), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Log In", for: .normal)
        
        let orange = UIColor(red: 234, green: 91, blue: 0, alpha: 1)
        button.setTitleColor(orange, for: .normal)
        
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundColor = UIColor(red: 202/255, green: 187/255, blue: 154/255, alpha: 1)
        view.backgroundColor = backgroundColor
        setupViews()
        setupConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        [appIcon, loginButton, signupButton].forEach{
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        
        appIcon.heightAnchor.constraint(equalToConstant: 200).isActive = true
        appIcon.widthAnchor.constraint(equalToConstant: 200).isActive = true
        appIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        appIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        loginButton.topAnchor.constraint(equalTo: appIcon.bottomAnchor, constant: 50).isActive = true
        loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30).isActive = true
        signupButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        signupButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        signupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    @objc private func login() {
        let mapView =  MapViewController()
        navigationController?.pushViewController(mapView, animated: true)
    }
    
    @objc private func signup() {
        print("Signup")
        
    }
    
}

