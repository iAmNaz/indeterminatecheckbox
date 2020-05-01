//
//  Node.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 5/1/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import Foundation
import Combine

class Node {
    
    /// An obervable property for state changes
    @Published var state: SelectionState = .none

    var data: SelectionReceiver? {
        return weakReceiver
    }
    
    private var isParent: Bool {
        return childrenNodes != nil
    }
    
    private var level: Int = 0
    private var index: Int = 0
    private var parent: Node?
    private(set) var childrenNodes:[Node]?
    private var selected = State.off
    private weak var weakReceiver: SelectionReceiver?
    
    /// The primary Initializer for this `Node`
    ///
    /// - Note: The node will create weak reference to receivers
    /// - Parameter data: Any type provided it conforms to the `SelectionReceiver` protocol
    init(data: SelectionReceiver) {
        data.link(node: self)
        self.weakReceiver = data
    }
    
    /// Method to add children
    /// - Parameter data: Any type provided it conforms to the `SelectionReceiver` protocol
    /// - Returns: `Node` object where other objects could pair with
    @discardableResult
    func addChild(data: SelectionReceiver) -> Node {
        
        let child = Node(data: data)
        
        data.link(node: child)
        
        if childrenNodes == nil {
            childrenNodes = [Node]()
        }
        
        child.level = level + 1
        child.parent = self
        child.index = childrenNodes!.endIndex
        childrenNodes!.append(child)
        return child
    }
    
    /// An extenal object can select a node
    /// - Parameter isSelected: A boolean value indicating if the node is selected or not
    func select(isSelected: Bool) {
        if isSelected {
            if isParent {
                selectDownStream()
            } else {
                setSelected()
            }
        } else {
            if isParent {
                deselectDownStream()
            } else {
                deselect()
            }
        }
    }
    
    // MARK: Private
    fileprivate func selectDownStream() {
        childrenNodes?.forEach { node in
            node.setSelected()
            node.selectDownStream()
        }
    }
    
    fileprivate func deselectDownStream() {
        childrenNodes?.forEach { node in
            node.deselect()
            node.deselectDownStream()
        }
    }
    
    private func deselect() {
        updateState(state: .none)
        evalChildSelections()
    }
    
    private func setSelected() {
        updateState(state: .selected)
        evalChildSelections()
    }
        
    // Scan children for changes
    private func evalChildSelections() {
        if let children = self.childrenNodes {
            let sum = children.reduce(0, { (result, node) -> Int in
                result + node.selected
            })
            
            switch sum {
            case 0:
                updateState(state: . none)
            case children.count:
                updateState(state: .selected)
            default:
                updateState(state: .indeterminate)
                
            }
        }
        parent?.evalChildSelections()
    }
    
    private func updateState(state: SelectionState) {
        self.state = state
        if state == .selected {
            selected = State.on
        } else {
            selected = State.off
        }
        
        weakReceiver?.didChange(state: self.state)
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        let tab = "\t"
        var tabs = ""
        
        for _ in 0...level {
            tabs += tab
        }
        
        let desc = weakReceiver?.debugDescription ?? ""
        
        return "\(tabs) \(String(describing: desc))"
    }
}
