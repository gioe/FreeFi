//
//  AddressForm.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/6/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit

public protocol FormSubmissionDelegate {
    func submitForm(form: JSONDictionary)
}

class AddressForm: UIStackView {
    
    public var submissionDelegate: FormSubmissionDelegate?
    
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
        row.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return row
    }()
    
    public let networkSectionHeader: FormSectionHeader = {
        let row = FormSectionHeader()
        row.textLabel.text = "Network Info"
        row.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return row
    }()
    
    public let nameRow: TextInputView = {
        let row = TextInputView()
        row.textLabel.text = "Name"
        row.textInput.placeholder = "Enter Name Here"
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return row
    }()
    
    public let addressRow: TextInputView = {
        let row = TextInputView()
        row.textLabel.text = "Address"
        row.textInput.placeholder = "Enter Address Here"
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return row
    }()
    
    public let networkRow: NetworkInputView = {
        let row = NetworkInputView()
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return row
    }()
    
    private let submissionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Add Spot", for: .normal)
        let yellow = UIColor(red: 234, green: 91, blue: 0, alpha: 1)
        button.setTitleColor(yellow, for: .normal)
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
        
        guard let name = nameRow.textInput.text, let address = addressRow.textInput.text else {
            print("Fill out rows")
            return
        }
        
        var json: [String: AnyObject] = ["name": name as AnyObject, "address": address as AnyObject]
        
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
        let row = NetworkInputView()
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true
        row.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        row.addDelegate = self
        insertArrangedSubview(row, at: self.subviews.count - 1)
    }
    
}

