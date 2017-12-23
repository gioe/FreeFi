//
//  SpotDetailViewController.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/8/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftSpinner

class SpotDetailViewController: UIViewController {
    
    enum DetailViewType {
        case empty
        case new (location: CLLocation)
        case existing (spot: Spot)
        
        var name: String? {
            switch self {
            case .existing(let spot):
                return spot.name
            default:
                return nil
            }
        }
        
        var address: String? {
            switch self {
            case .existing(let spot):
                return spot.address
            default:
                return nil
            }
        }
        
        var city: String? {
            switch self {
            case .existing(let spot):
                return spot.city
            default:
                return nil
            }
        }
        
        var state: String? {
            switch self {
            case .existing(let spot):
                return spot.state
            default:
                return nil
            }
        }
        
        var location: CLLocation? {
            switch self {
            case .new(let location):
                return location
            default:
                return nil
            }
        }
        
        var networks: [Network]? {
            switch self {
            case .existing(let spot):
                return spot.networks
            default:
                return nil
            }
        }
    }
    
    var submissionDelegate: Submittable?
    public var addressForm = AddressForm(viewType: .empty)
    public var viewType: DetailViewType!
    
    public init(type: DetailViewType) {
        viewType = type
        addressForm = AddressForm(viewType: type)
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = ColorConstant.basicBrown.color
    }
    
    public convenience init() {
        self.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
    
        addressForm.textDelegate = self
        addressForm.submissionDelegate = self
        addressForm.errorDelegate = self
        
        addressForm.translatesAutoresizingMaskIntoConstraints = false
        
        [addressForm].forEach{
            view.addSubview($0)
        }
        
    }
    
    func setupConstraints() {
        addressForm.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        addressForm.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        addressForm.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        addressForm.heightAnchor.constraint(equalToConstant: addressForm.intrinsicContentSize.height).isActive = true
    }
    
}

extension SpotDetailViewController: FormErrorPresentable {
   
    func presentErrorOfType(_ type: AddressForm.FormError) {
        let alertController = UIAlertController(title: "Alert", message: type.errorMessage, preferredStyle: .alert)
       
        let action1 = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension SpotDetailViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}

extension SpotDetailViewController: FormSubmissionDelegate {
    
    public func submitSpot(spot: Spot) {
        
        SpotsService.sharedInstance.postSpot(spot) { (response, error) in
            guard error == nil else {
                return
            }
            SwiftSpinner.hide({
                self.submissionDelegate?.submittedForm()
            })
        }
    }
    
}

