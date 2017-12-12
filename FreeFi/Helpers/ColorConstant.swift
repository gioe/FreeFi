//
//  ColorConstants.swift
//  FreeFi
//
//  Created by Matt on 12/11/17.
//  Copyright © 2017 Matt. All rights reserved.
//

import Foundation
import UIKit

public enum ColorConstant {
    case basicBrown
    case lightBrown
    case middleBrown
    case darkBrown
    case yellow

    var color: UIColor {
        switch self {
        case .basicBrown:   return UIColor(red: 202/255, green: 187/255, blue: 154/255, alpha: 1)
        case .lightBrown:   return UIColor(red: 202/255, green: 187/255, blue: 154/255, alpha: 1)
        case .middleBrown:  return UIColor(red: 202/255, green: 187/255, blue: 154/255, alpha: 1)
        case .darkBrown:    return UIColor(red: 202/255, green: 187/255, blue: 154/255, alpha: 1)
        case .yellow:       return UIColor(red: 234, green: 91, blue: 0, alpha: 1)
        }
    }
}
