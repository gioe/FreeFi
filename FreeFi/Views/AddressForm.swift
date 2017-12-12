//
//  AddressForm.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/6/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import SwiftSpinner

internal protocol FormErrorPresentable {
    func presentErrorOfType(_ type: AddressForm.FormError)
}

public protocol FormSubmissionDelegate {
    func submitForm(form: JSONDictionary)
}

internal class AddressForm: UIStackView {
    
    internal enum FormError {
        case emptyNetwork
        case emptyForm
        
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

    public var isEmpty: Bool {
        guard !nameRow.isEmpty, !addressRow.isEmpty, !networkRows.isEmpty else {
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
        row.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return row
    }()
    
    public let networkSectionHeader: FormSectionHeader = {
        let row = FormSectionHeader()
        row.textLabel.text = "Network Info"
        row.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return row
    }()
    
    public let nameRow: TextInputView = {
        let row = TextInputView()
        row.textLabel.text = "Name"
        row.textLabel.textColor = .white
        row.textInput.placeholder = "Enter Name Here"
        row.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return row
    }()
    
    public let addressRow: TextInputView = {
        let row = TextInputView()
        row.textLabel.text = "Address"
        row.textLabel.textColor = .white
        row.textInput.placeholder = "Enter Address Here"
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
    
    @objc func submitForm() {
        
        SwiftSpinner.show("Submitting...")
        
        guard !isEmpty else {
            errorDelegate?.presentErrorOfType(.emptyForm)
            SwiftSpinner.hide()
            return
        }
        
        var json: [String: AnyObject] = ["name": nameRow.textInput.text! as AnyObject, "address": addressRow.textInput.text! as AnyObject]
        
        var networkArray: [JSONDictionary] = []
        
        self.subviews.forEach{
            if let networkView = $0 as? NetworkInputView, let networkName = networkView.networkNameInput.text, let password =  networkView.passwordInput.text, !networkName.isEmpty {
                networkArray.append(["name": networkName as AnyObject, "password": password as AnyObject])
            }
        }
        
        json["networks"] = networkArray as AnyObject
        
        submissionDelegate?.submitForm(form: [:] as JSONDictionary)
        
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
        
        insertArrangedSubview(networkSectionHeader, at: 3)
        
        insertArrangedSubview(networkRow, at: 4)
        insertArrangedSubview(submissionButton, at: 5)
        
    }
    
    override func layoutSubviews() {
        [basicSectionHeader, nameRow, addressRow, networkRow, networkSectionHeader].forEach{
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

