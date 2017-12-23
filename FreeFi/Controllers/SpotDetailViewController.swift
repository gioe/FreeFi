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
    
    private var scrollView: UIScrollView = {
        var view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
    
        addressForm.textDelegate = self
        addressForm.submissionDelegate = self
        addressForm.errorDelegate = self
        
        addressForm.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(addressForm)
        
        [scrollView].forEach{
            view.addSubview($0)
        }
        
    }
    
    func setupConstraints() {
        
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        addressForm.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        addressForm.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        addressForm.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        addressForm.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        addressForm.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    @objc func keyboardWillShow() {
        if addressForm.networkRow.networkNameInput.isFirstResponder || addressForm.networkRow.passwordInput.isFirstResponder {
            let yCoordinate = addressForm.stateRow.frame.origin.y
            scrollView.contentOffset = CGPoint(x: 0.0, y: yCoordinate)
        }
    }
    
    @objc func keyboardWillHide() {
        scrollView.contentOffset = CGPoint(x: 0.0, y: -64.0)
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

