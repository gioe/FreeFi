//
//  AddressForm.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/6/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import SwiftSpinner
import GooglePlaces
import CoreLocation

internal protocol FormErrorPresentable {
    func presentErrorOfType(_ type: AddressForm.FormError)
}

public protocol FormSubmissionDelegate {
    func submitSpot(spot: Spot)
}

internal class AddressForm: UIStackView {
    
    internal enum FormError: Error {
        case emptyNetwork
        case emptyForm
        case spotCreation

        var errorMessage: String {
            switch self {
            case .emptyForm:
                return "Form is not sufficiently filled out. Please check that all relevant information is filled in and resubmit."
            default:
                return "Can't add another network before filling in the last one."
            }
        }
    }
    
    public var submissionDelegate: FormSubmissionDelegate?
    public var errorDelegate: FormErrorPresentable?
    private var constructedAddress = ""
    lazy var geocoder = CLGeocoder()

    public var isEmpty: Bool {
        guard !nameRow.isEmpty, !addressRow.isEmpty, !stateRow.isEmpty, !networkRows.isEmpty else {
            return true
        }
        return false
    }
    
    public var networkRows: [NetworkInputView] {
        return subviews.filter{$0 is NetworkInputView}.map{$0 as! NetworkInputView}
    }
    
    public var viewType: SpotDetailViewController.DetailViewType? = nil {
        didSet {
            switch viewType {
            case .existing( _)?:
                submissionButton.setTitle("Update Spot", for: .normal)
            default:
                submissionButton.setTitle("Add Spot", for: .normal)
            }
        }
    }
    
    public let basicSectionHeader: FormSectionHeader = {
        let row = FormSectionHeader()
        row.textLabel.text = "Basic Info"
        row.textLabel.font = UIFont.boldSystemFont(ofSize: 15)
        row.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return row
    }()
    
    public let networkSectionHeader: FormSectionHeader = {
        let row = FormSectionHeader()
        row.textLabel.text = "Network Info"
        row.textLabel.font = UIFont.boldSystemFont(ofSize: 15)
        row.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return row
    }()
    
    public let nameRow: TextInputView = {
        let row = TextInputView()
        row.textInput.placeholder = "Name"
        row.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return row
    }()
    
    public let addressRow: TextInputView = {
        let row = TextInputView()
        row.textInput.placeholder = "Address"
        row.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return row
    }()
    
    public let stateRow: DoubleTextInputView = {
        let row = DoubleTextInputView()
        row.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return row
    }()
    
    public lazy var networkRow: NetworkInputView = {
        let row = NetworkInputView()
        row.heightAnchor.constraint(equalToConstant: 70).isActive = true
        row.addDelegate = self
        return row
    }()
    
    private let submissionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Add Spot", for: .normal)
        button.setTitleColor(ColorConstant.basicBrown.color, for: .normal)
        button.addTarget(self, action: #selector(submitForm), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return button
    }()
    
    public convenience init(viewType: SpotDetailViewController.DetailViewType) {
        self.init(frame: .zero)
        self.viewType = viewType
        configureView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSpot(completion: @escaping (_ spot: Spot?, _ error: Error?) -> Void) {
        
        guard let street = addressRow.textInput.text else { return }
        guard let city = stateRow.cityInput.text else { return }
        guard let state = stateRow.stateInput.text else { return }

        // Create Address String
        let address = "\(street), \(city), \(state)"
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // Process Response
            guard error == nil, let spot = self.processResponse(withPlacemarks: placemarks) else {
                completion(nil, error)
                return
            }
            completion(spot, nil)
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?) -> Spot? {
       
        guard let placemarks = placemarks, let firstPlace = placemarks.first, let name = nameRow.textInput.text, let number = firstPlace.subThoroughfare, let street = firstPlace.thoroughfare, let city = firstPlace.locality, let state = firstPlace.administrativeArea, let zip = firstPlace.postalCode, let zipInt = Int(zip), let latitude = firstPlace.location?.coordinate.latitude, let longitude = firstPlace.location?.coordinate.longitude else { return nil }
        
        let address = number + " " + street
        
        return Spot(name: name, address: address, city: city, state: state, zipCode: zipInt, latitude: latitude, longitude: longitude)
    }
    
    public func injectPlaceIntoForm(place: GMSPlace) {
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypeStreetNumber:
                    constructedAddress += field.name
                case kGMSPlaceTypeRoute:
                    constructedAddress += " " + field.name
                case kGMSPlaceTypeLocality:
                    stateRow.cityInput.text = field.name
                case kGMSPlaceTypeStreetAddress:
                    addressRow.textInput.text = field.name
                case kGMSPlaceTypeAdministrativeAreaLevel1:
                    stateRow.stateInput.text = field.name
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
            if addressRow.textInput.text == "" {
                addressRow.textInput.text = constructedAddress
            }
        }
    }
    
    @objc func submitForm() {
        
        SwiftSpinner.show("Submitting...")
        
        guard !isEmpty else {
            errorDelegate?.presentErrorOfType(.emptyForm)
            SwiftSpinner.hide()
            return
        }
        
        createSpot { (spot, error) in
        
            guard error == nil, let spot = spot else {
                return
            }
            
            var spotCopy = spot
            var networkArray: [Network] = []
            
            self.subviews.forEach{
                if let networkView = $0 as? NetworkInputView, let networkName = networkView.networkNameInput.text, let password =  networkView.passwordInput.text, !networkName.isEmpty, !password.isEmpty {
                    let network = Network(name: networkName, password: password)
                    networkArray.append(network)
                }
            }
            
            spotCopy.networks = networkArray
            
            self.submissionDelegate?.submitSpot(spot: spotCopy)
        }
    }
    
    func configureView() {
        
        if let viewType = viewType, let address = viewType.address, let name = viewType.name {
            nameRow.textInput.text = name
            addressRow.textInput.text = address
        }
        
        setupNetworks()
        
        axis = .vertical
        alignment = .center
        distribution = .fillProportionally
        spacing = 0.0
        
        insertArrangedSubview(basicSectionHeader, at: 0)
        insertArrangedSubview(nameRow, at: 1)
        insertArrangedSubview(addressRow, at: 2)
        insertArrangedSubview(stateRow, at: 3)

        insertArrangedSubview(networkSectionHeader, at: 4)
        
        insertArrangedSubview(networkRow, at: 5)
        insertArrangedSubview(submissionButton, at: 6)
        
    }
    
    override func layoutSubviews() {
        [basicSectionHeader, nameRow, addressRow, stateRow, networkRow, networkSectionHeader].forEach{
            $0.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
        }
    }
    
    func setupNetworks() {
        
        guard let viewType = viewType, let networks = viewType.networks else {
            return
        }
        
        for (index, element) in networks.enumerated() {
            switch index {
            case 0:
                networkRow.addDelegate = self
                networkRow.setData(network: element)
            default:
                addNewRow()
                if let addedRow = subviews[subviews.count - 1] as? NetworkInputView {
                    addedRow.setData(network: element)
                }
            }
        }
    }
    
}

extension AddressForm: AddRowDelegate {
    
    internal func addNewRow() {
        
        guard let lastNetworkRow = subviews[subviews.count - 1] as? NetworkInputView, !lastNetworkRow.isEmpty else {
            errorDelegate?.presentErrorOfType(.emptyNetwork)
            return
        }
        
        lastNetworkRow.addButton.isHidden = true
        let row = NetworkInputView()
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true
        row.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        row.addDelegate = self
        insertArrangedSubview(row, at: self.subviews.count - 1)
    }
    
}

