//
//  Protocols.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import UIKit

/// Type that conforms to this protocol will be able to provide a title
protocol Labelable {
    var title: String { get set }
}

/// Use to get the cell identifier
protocol ReuseIdentifier {
    var cellIdentifier: String { get }
}

/// A given cell should conform to to ensure that cells have consistent
/// model types
protocol FieldCell {
    var model: Row! { get set }
    var style: CheckBoxStyle! { get set }
}

/// If a user intends to set their own style just pass an instance of a class or struct that conforms to this protocol
protocol CheckBoxStyle {
    func indeterminateStyle() -> UIColor
    func defaultStyle() -> UIColor
    func selectedStyle() -> UIColor
}
