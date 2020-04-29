//
//  UIKit+Extensions.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import UIKit

/// Cell registration extension
extension UITableView {
    func register<T>(aClass:  T.Type = T.self) {
        let identifier = String(describing: aClass)
        self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
}

/// It helps in simplyfying the cell setup
extension UITableViewCell {
    
    var rowModel: Row {
        get {
            return (self as! FieldCell).model
        }
        set {
            var row = (self as! FieldCell)
            row.model = newValue
        }
    }
    
    var rowStyle: CheckBoxStyle {
        get {
            return (self as! FieldCell).style
        }
        set {
            var row = (self as! FieldCell)
            row.style = newValue
        }
    }
}

