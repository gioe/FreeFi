//
//  MainTabBarViewController.swift
//  FreeFi
//
//  Created by Matt on 12/8/17.
//  Copyright © 2017 Matt. All rights reserved.
//

import UIKit

public protocol Submittable {
    func submittedForm()
}

public protocol Refreshable {
    func refreshData()
}

class MainTabBarViewController: UITabBarController {
    
    public var refreshDelegate: Refreshable?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupViewControllers()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView () {
        navigationItem.title = "FreeFi"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .done, target: self, action: #selector(refreshData))
        
        delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupViewControllers() {
        let mapView = MapViewController()
        mapView.view.backgroundColor = .white
        refreshDelegate = mapView
        mapView.tabBarItem = UITabBarItem(title: "Current Spot", image: #imageLiteral(resourceName: "pin"), selectedImage: #imageLiteral(resourceName: "pin"))
        
        let spotDetailView = SpotDetailViewController(type: .empty)
        spotDetailView.tabBarItem = UITabBarItem(title: "Add Spot", image: #imageLiteral(resourceName: "add"), selectedImage: #imageLiteral(resourceName: "add"))
        
        viewControllers = [mapView, spotDetailView]
    }

    @objc private func refreshData() {
        refreshDelegate?.refreshData()
    }
    
}

extension MainTabBarViewController: Submittable {
    public func submittedForm() {
        if let viewControllers = viewControllers, let mapVc = viewControllers[0] as? MapViewController {
           self.selectedViewController = mapVc
        }
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch viewController {
        case let spotVc as SpotDetailViewController:
            if let viewControllers = viewControllers, let mapVc = viewControllers[0] as? MapViewController {
                spotVc.viewType = mapVc.generateCurrentSpot()
            }
        case let mapVc as MapViewController:
            mapVc.refreshData()
        default: break
        }
        
    }
    
}

