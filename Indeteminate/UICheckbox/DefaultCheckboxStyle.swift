//
//  DefaultCheckboxStyle.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/29/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import UIKit

/// Sample checkbox styling
struct DefaultCheckboxStyle: CheckBoxStyle {
    func indeterminateStyle() -> UIColor {
        return UIColor(red: 1, green: 238/255.0, blue: 173/255.0, alpha: 1.0)
    }
    
    func defaultStyle() -> UIColor {
        return UIColor(red: 1, green: 111/255.0, blue: 105/255.0, alpha: 1.0)
    }
    
    func selectedStyle() -> UIColor {
        return UIColor(red: 150/255.0, green: 206/255.0, blue: 180/255.0, alpha: 1.0)
    }
}

struct CustomCheckboxStyle: CheckBoxStyle {
    func indeterminateStyle() -> UIColor {
        return .yellow
    }
    
    func defaultStyle() -> UIColor {
        return .red
    }
    
    func selectedStyle() -> UIColor {
        return .green
    }
}
