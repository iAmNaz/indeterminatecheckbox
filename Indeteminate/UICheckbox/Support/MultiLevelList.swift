//
//  MultiLevelList.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import Foundation
import Combine

/// Selection state options of a given check box
enum SelectionState {
    case none
    case selected
    case indeterminate
}

/// Encapsulates the on/off value
struct State {
    static var on = 1
    static var off = 0
}

/// List item models will conform to this protocol to
/// be able to interface with the tree data model.
protocol SelectionReceiver: class {
    
    /// Will be needed if we want to locate it later
    var identifier: String { get set }
    
    /// A getter method to ask for child models
    /// - Returns: `SelectionReceiver`
    func childNodes() -> [SelectionReceiver]?
    
    /// Implement this method that gets called
    /// when node state changes comes from the
    /// tree
    /// - Parameter state: The incoming state value
    func didChange(state: SelectionState)
    
    /// A method to link the row model with a given `Node`
    /// - Note: The link must be weak to avoid a strong reference cycle
    /// - Parameter node: A given to pair with
    func link(node: Node)
    
    /// An internal debugging info
    var debugDescription: String? { get }
}

/// The model that backs the checkbox
class MultiLevelList<T> where T:Labelable {
    
    var root: Node!
    
    var store = Set<AnyCancellable>()
    
    init(root receiver: SelectionReceiver, list items: [SelectionReceiver]) {
        
        // Root Level
        self.root = Node(data: receiver)

        items.forEach { (parentRow) in
            // Level 2
            let parentNode = self.root.addChild(data: parentRow)
                  
            // Level 2 Children
            if let childRows = parentRow.childNodes() {
                for child in childRows {
                    parentNode.addChild(data: child)
                }
            }
        }
    }
    
    
    func allItems() -> [Node] {
        var items = [Node]()
        items.append(root)
        
        if let children = root.childrenNodes {
            self.getAllChildren(children: children, items: &items)
        }
        return items
    }
    
    func getAllChildren(children: [Node], items: inout [Node]) {
        children.forEach { (node) in
            items.append(node)
            if let childNodes = node.childrenNodes {
                getAllChildren(children: childNodes, items: &items)
            }
        }
    }
    
    func node(for data: SelectionReceiver) -> Node? {
        var matchingNode: Node?
        allItems().forEach { (node) in
            if let nodeData = node.data {
                if nodeData.identifier == data.identifier {
                    matchingNode = node
                }
            }
        }
        return matchingNode
    }
    
    func node(withID identifier: String) -> Node? {
        var matchingNode: Node?
        allItems().forEach { (node) in
            if let nodeData = node.data {
                if nodeData.identifier == identifier {
                     matchingNode = node
                }
            }
        }
        return matchingNode
    }
}

