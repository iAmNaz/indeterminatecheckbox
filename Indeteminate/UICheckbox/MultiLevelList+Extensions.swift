//
//  MultiLevelList+Extensions.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/29/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import Foundation

/// Some custom methods that helps in associating the data model to the multilevel list
extension MultiLevelList {
    
    func customData(rootItem: Row,items: [Row]) {
        
        bind(node: self.root, row: rootItem)
        
        for item in items {
      
            let node = self.node(with: item)
            
            self.root.addChild(child: node)
                  
            if let subItems = item.children {
                for child in subItems {
                    let childNode = self.node(with: child)
                    node.addChild(child: childNode)
                }
            }
        }
    }
    
    func node(with row: Row) -> Node {
        let node = Node(title: row.title)
        
        bind(node: node, row: row)
        
        return node
    }
    
    func bind(node: Node, row: Row) {
        let cancellable = node.$state
            .subscribe(row.stateReceiver)
        store.insert(cancellable)
                
                row.$selectReceiver
                    .sink { (isSelected) in
                    if isSelected {
                        if node.isParent {
                            node.selectDownStream()
                        } else {
                            node.setSelected()
                        }
                        
                    } else {
                        if node.isParent {
                            node.deselectDownStream()
                        } else {
                            node.deselect()
                        }
                    }
                }
                .store(in: &store)
    }
}
