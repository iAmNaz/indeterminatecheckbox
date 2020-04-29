//
//  ViewController.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import UIKit
import Combine

struct Item: Labelable {
    var title: String
}

class ViewController: UIViewController {

    var checkbox: UICheckbox<Item>!
    
    private var cancellables: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1. Create Data
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
        
        //2. Initialize
        checkbox = UICheckbox(rootItem: NSLocalizedString("Select All", comment: "root itle"), items: sample)
        
        //3. Add to superview
        checkbox.embedInContainer(container: self.view)
        
        //3. Optionally observe for changes
        let cancellable = checkbox.selectionObserver.sink { (row) in
            print(row)
        }
        
        //4. Make sure the cancellable is cached to make sure
        //   the observer will receive updates
        cancellables += [
            cancellable
        ]
    }
}

