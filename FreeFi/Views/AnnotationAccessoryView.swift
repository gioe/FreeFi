//
//  AnnotationAccessoryView.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/27/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import MapKit

public protocol CalloutSelectionDelegate {
    func clickedCallout(for annotation: MKAnnotation)
}

class AnnotationAccessoryView: UIView {
    
    var annotation: MKAnnotation?
    var selectionDelegate: CalloutSelectionDelegate?
    
    private var textLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public convenience init (annotation: MKAnnotation) {
        self.init(frame: .zero)
        self.annotation = annotation
        configureView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        if let subtitle = annotation?.subtitle {
            textLabel.text = subtitle
        }
        addSubview(textLabel)
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        addGestureRecognizer(tapGest)
    }
    
    @objc private func tappedView() {
        
        guard let annotation = annotation else {
            return
        }
        
        selectionDelegate?.clickedCallout(for: annotation)
    }
    
    override func layoutSubviews() {
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        textLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
}

