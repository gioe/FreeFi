//
//  SpotTableViewCell.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/8/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit

class SpotTableViewCell: UITableViewCell {
    
    var spot: Spot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setupCell() {
        textLabel?.text = spot?.name
    }
    
}

