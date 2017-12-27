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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        guard let viewType = viewType else {
            return
        }
        
        switch viewType {
        case .existing(_):
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editData))
            addressForm.mode = .readOnly
        default:
            addressForm.mode = .write
        }
        
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
   
    func presentError(_ error: InternalError) {
        let alertController = UIAlertController(title: "Error", message: error.errorMessage, preferredStyle: .alert)
       
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
            SwiftSpinner.hide()
            if let error = error {
                DispatchQueue.main.async {
                    self.presentError(error)
                }
                return
            }
            self.submissionDelegate?.submittedForm()
        }
    }
}

extension SpotDetailViewController: Editable {
    @objc func editData() {
        addressForm.mode = .write
    }
}

