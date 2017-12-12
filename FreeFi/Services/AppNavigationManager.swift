//
//  AppNavigationManager.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/1/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit

public class AppNavigationManager: NSObject {
    
    public static let shared = AppNavigationManager()
    
    var currentRootView: UIViewController? {
        didSet {
            currentWindow.rootViewController = currentRootView
            currentWindow.makeKeyAndVisible()
        }
    }
    public var currentWindow: UIWindow!
    
    override private init() {
        super.init()
    }
    
    public func beginBoostrap(window: UIWindow) {
        currentWindow = window
        presentSplash()
        ServicesManager.shared.initializeServices()
        determineRootView()
    }
    
    private func determineRootView() {
        let tabBarVc = MainTabBarViewController()
        let navigationController = UINavigationController(rootViewController: tabBarVc)
        navigationController.setNavigationBarHidden(false, animated: false)
        currentRootView = navigationController
        
    }
    
    private func presentSplash() {
    }
}

