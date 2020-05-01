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

struct State {
    static var on = 1
    static var off = 0
}

protocol SelectionReceiver: class {
    func childNodes() -> [SelectionReceiver]?
    func didChange(state: SelectionState)
    func link(node: Node)
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
    
    func selectAll() {
        root.selectDownStream()
    }
    
    func deselectAll() {
        root.deselectDownStream()
    }
    
    func debugPrintSelections() {
        root.debugPrintSelections()
    }
}

class Node {
    
    /// An obervable property
    @Published var state: SelectionState = .none
    
    /// Property to determine if this node has children
    var isParent: Bool {
        return childrenNodes != nil
    }
    
    private var level: Int = 0
    private var index: Int = 0
    private var parent: Node?
    private var childrenNodes:[Node]?
    private var selected = State.off
    private weak var weakReceiver: SelectionReceiver?
    
    init(data: SelectionReceiver) {
        data.link(node: self)
        self.weakReceiver = data
    }
    
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
    
    fileprivate func debugPrintSelections() {
        childrenNodes?.forEach {
            $0.debugPrintSelections()
        }
    }
    
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
    
    func updateState(state: SelectionState) {
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
