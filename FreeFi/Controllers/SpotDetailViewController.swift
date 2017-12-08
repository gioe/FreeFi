//
//  SpotDetailViewController.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/8/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import CoreLocation

class SpotDetailViewController: UIViewController {
    
    enum DetailViewType {
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
    
    var addressForm: AddressForm?
    private var viewType: DetailViewType!
    
    public init(type: DetailViewType) {
        self.viewType = type
        self.addressForm = AddressForm(viewType: type)
        super.init(nibName: nil, bundle: nil)
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
        
        guard let addressForm = addressForm else {
            return
        }
        
        addressForm.nameRow.textInput.delegate = self
        addressForm.addressRow.textInput.delegate = self
        
        addressForm.submissionDelegate = self
        
        addressForm.translatesAutoresizingMaskIntoConstraints = false
        
        [addressForm].forEach{
            view.addSubview($0)
        }
        
    }
    
    func setupConstraints() {
        
        guard let addressForm = addressForm else {
            return
        }
        
        addressForm.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        addressForm.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        addressForm.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        addressForm.heightAnchor.constraint(equalToConstant: addressForm.intrinsicContentSize.height).isActive = true
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
    
    public func submitForm(form: JSONDictionary) {
        
        guard let viewType = viewType, let location = viewType.location else {
            return
        }
        
        var copy = form
        copy["latitude"] = location.coordinate.latitude as AnyObject
        copy["longitude"] =  location.coordinate.longitude as AnyObject
        
        if let spot = Spot(dictionary: copy) {
            SpotsService.sharedInstance.postSpot(spot) { (response, error) in
                guard error == nil else {
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
}

