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

public protocol InternalError {
    var errorMessage: String { get }
}

internal protocol FormErrorPresentable {
    func presentError(_ error: InternalError)
}

public protocol FormSubmissionDelegate {
    func submitSpot(spot: Spot)
    func updateSpot(spot: Spot)
}

internal class AddressForm: UIStackView {
    
    typealias SpotCreationCompletion = (_ spot: Spot?, _ error: Error?) -> Void
    
    enum Mode {
        case readOnly
        case write
    }
    
    internal enum FormError: InternalError, Error {
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
    public var currentSpot: Spot? = nil
    public var viewType: SpotDetailViewController.DetailViewType = .empty
    public var mode: Mode = .readOnly {
        didSet {
            switch mode {
            case .readOnly:
                setupReadOnly()
            default:
                setupWrite()
            }
        }
    }

    public var isEmpty: Bool {
        guard !nameRow.isEmpty, !addressRow.isEmpty, !stateRow.isEmpty, !networkRows.isEmpty else {
            return true
        }
        return false
    }
    
    public var networkRows: [NetworkInputView] {
        return subviews.filter{$0 is NetworkInputView}.map{$0 as! NetworkInputView}
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
    
    public var networkRow: NetworkInputView = {
        let row = NetworkInputView()
        row.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return row
    }()
    
    public let submissionButton: UIButton = {
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
    
    public var textDelegate: UITextFieldDelegate? {
        didSet {
            nameRow.textInput.delegate = textDelegate
            addressRow.textInput.delegate = textDelegate
            stateRow.cityInput.delegate = textDelegate
            stateRow.stateInput.delegate = textDelegate
            networkRow.networkNameInput.delegate = textDelegate
            networkRow.passwordInput.delegate = textDelegate
        }
    }
    
    public convenience init(viewType: SpotDetailViewController.DetailViewType) {
        self.init(frame: .zero)
        self.viewType = viewType
        switch viewType {
        case .existing(let spot):
            self.currentSpot = spot
        default: break
        }
        configureView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        
        if let currentSpot = currentSpot {
            nameRow.textInput.text = currentSpot.name
            addressRow.textInput.text = currentSpot.address
            stateRow.cityInput.text = currentSpot.city
            stateRow.stateInput.text = currentSpot.state
        }
        
        networkRow.addDelegate = self
        
        axis = .vertical
        alignment = .center
        distribution = .fillProportionally
        spacing = 0.0
        
        for (index, element) in [basicSectionHeader, nameRow, addressRow, stateRow, networkSectionHeader, networkRow, submissionButton].enumerated() {
            insertArrangedSubview(element, at: index)
        }
      
        setupNetworkRows()
    }
    
    func setupNetworkRows() {
        guard let currentSpot = currentSpot, let networks = currentSpot.networks else {
            return
        }
        
        for (index, element) in networks.enumerated() {
            switch index {
            case 0:
                networkRow.addDelegate = self
                networkRow.setData(network: element)
            default:
                addNewRow()
                if let addedRow = arrangedSubviews[arrangedSubviews.count - 1] as? NetworkInputView {
                    addedRow.setData(network: element)
                }
            }
        }
    }
    
    func postSpot(_ spot: Spot?, _ error: Error?) {
        guard error == nil, let spot = spot else {
            self.errorDelegate?.presentError(FormError.spotCreation)
            return
        }
        
        var spotCopy = spot
        var networkArray: [Network] = []
        
        for (index, networkRow) in networkRows.enumerated() {
            if let networkName = networkRow.networkNameInput.text, let password =  networkRow.passwordInput.text, !networkRow.isEmpty, !networkRow.isEmpty {
                let network = Network(id: currentSpot?.networks?[index].id ?? 0, name: networkName, password: password)
                networkArray.append(network)
            }
        }
       
        
        spotCopy.networks = networkArray
        
        switch self.viewType {
        case .existing(_):
            self.submissionDelegate?.updateSpot(spot: spotCopy)
        default:
            self.submissionDelegate?.submitSpot(spot: spotCopy)
        }
    }
    
    func createSpot(completion: @escaping SpotCreationCompletion) {
        
        guard let street = addressRow.textInput.text else { return }
        guard let city = stateRow.cityInput.text else { return }
        guard let state = stateRow.stateInput.text else { return }

        // Create Address String
        let address = "\(street), \(city), \(state)"
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // Process Response
            guard error == nil, let spot = self.processResponse(withPlacemarks: placemarks) else {
                completion(nil, FormError.spotCreation)
                return
            }
            completion(spot, nil)
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?) -> Spot? {
       
        guard let placemarks = placemarks, let firstPlace = placemarks.first, let name = nameRow.textInput.text, let number = firstPlace.subThoroughfare, let street = firstPlace.thoroughfare, let city = firstPlace.locality, let state = firstPlace.administrativeArea, let zip = firstPlace.postalCode, let zipInt = Int(zip), let latitude = firstPlace.location?.coordinate.latitude, let longitude = firstPlace.location?.coordinate.longitude else { return nil }
        
        let address = number + " " + street
        
        return Spot(id: currentSpot?.id ?? 0, name: name, address: address, city: city, state: state, zipCode: zipInt, latitude: latitude, longitude: longitude)
        
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
            errorDelegate?.presentError(FormError.emptyForm)
            SwiftSpinner.hide()
            return
        }
        createSpot(completion: self.postSpot(_:_:))
    }
        
    override func layoutSubviews() {
        [basicSectionHeader, nameRow, addressRow, stateRow, networkRow, networkSectionHeader].forEach{
            $0.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
        }
    }

    public func refreshForm() {
        constructedAddress = ""
        nameRow.textInput.text = nil
        addressRow.textInput.text = nil
        stateRow.stateInput.text = nil
        stateRow.cityInput.text = nil
        networkRows.forEach {
            $0.addButton.isHidden = false
            $0.networkNameInput.text = nil
            $0.passwordInput.text = nil
        }
        while arrangedSubviews.count > 7 {
            arrangedSubviews[5].removeFromSuperview()
        }
    }
    
    func setupWrite() {
        submissionButton.isHidden = false
        isUserInteractionEnabled = true
        for (index, networkRow) in networkRows.enumerated() {
            switch index {
            case networkRows.count - 1:
                networkRow.addButton.isHidden = false
                networkRow.deleteButton.isHidden = false
            default:
                networkRow.deleteButton.isHidden = false
            }
        }
    }
    
    func setupReadOnly() {
        submissionButton.isHidden = true
        networkRows.forEach{
            $0.addButton.isHidden = true
            $0.deleteButton.isHidden = true
        }
        isUserInteractionEnabled = false
    }
    
}

extension AddressForm: AddRowDelegate {
    
    internal func addNewRow() {
        guard let lastNetworkRow = arrangedSubviews[5] as? NetworkInputView, !lastNetworkRow.isEmpty else {
            errorDelegate?.presentError(FormError.emptyNetwork)
            return
        }
        
        lastNetworkRow.addButton.isHidden = true
        lastNetworkRow.passwordInput.resignFirstResponder()
        lastNetworkRow.networkNameInput.resignFirstResponder()
        let row = NetworkInputView()
        row.networkNameInput.delegate = textDelegate
        row.passwordInput.delegate = textDelegate
        row.heightAnchor.constraint(equalToConstant: 70).isActive = true
        row.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        row.addDelegate = self
        self.networkRow = row
        insertArrangedSubview(row, at: 5)
    }
    
    internal func removeRow(row: NetworkInputView) {
        guard arrangedSubviews[5] != row else {
            return
        }
        row.removeFromSuperview()
    }

}

