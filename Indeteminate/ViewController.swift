//
//  ViewController.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import UIKit

struct Item: Labelable {
    var title: String
}

class ViewController: UIViewController {

    var checkbox: UICheckbox<Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sample = [
            "PARENT1": [Item(title: "item1"), Item(title: "item2")],
            "PARENT2": [Item(title: "item1"), Item(title: "item2")],
            "PARENT3": [Item(title: "item1"), Item(title: "item2"), Item(title: "item3"),Item(title: "item4")],
            "PARENT4": [Item(title: "item1"), Item(title: "item2"), Item(title: "item3"), Item(title: "item4")],
            "PARENT5": [Item(title: "item1"), Item(title: "item2")],
            "PARENT6": [Item(title: "item1"), Item(title: "item2"), Item(title: "item3"),Item(title: "item4")],
            "PARENT7": [Item(title: "item1"), Item(title: "item2"), Item(title: "item3"),Item(title: "item4")],
            "PARENT8": [Item(title: "item1"), Item(title: "item2"), Item(title: "item3"),Item(title: "item4")]
        ]
        
        checkbox = UICheckbox(items: sample)
        
        checkbox.embedInContainer(container: self.view)
    }


}

