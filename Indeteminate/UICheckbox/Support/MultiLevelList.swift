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

/// The model that backs the checkbox
class MultiLevelList<T> where T:Labelable {
    
    var root: Node!
    
    var store = Set<AnyCancellable>()
    
    /// Use this initializer when node are created externally
    init(title: String) {
        self.root = Node(title: title)
    }
    
    /// Use this initializer when you have an array of dictionary data
    /// and let the list generate the nodes
    init(title: String, items: [String:[T]]) {
          
          self.root = Node(title: title)
          
          for dict in items {
              
              let key = dict.key
              
              let subItems = dict.value
              
              let node = Node(title: key)
    
              self.root.addChild(child: node)
              
              for child in subItems {
                  node.addChild(child: Node(title: child.title))
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
    private var selected = 0
    private var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func addChild(child: Node) {
        if childrenNodes == nil {
            childrenNodes = [Node]()
        }
        child.level = level + 1
        child.parent = self
        child.index = childrenNodes!.endIndex
        childrenNodes!.append(child)
    }
    
    func selectDownStream() {
        parent?.selected = 1
        state = .selected
        childrenNodes?.forEach { node in
            node.selected = 1
            node.state = .selected
            node.selectDownStream()
        }
        parent?.evalSelections()
    }
    
    func deselectDownStream() {
        parent?.selected = 0
        state = .none
        childrenNodes?.forEach { node in
            node.selected = 0
            node.state = .none
            node.deselectDownStream()
        }
        parent?.evalSelections()
    }
    
    func deselect() {
        
        selected = 0
        
        // Select upstream
        parent?.deselect()
        
        guard let children = childrenNodes else {
            state = .none
            return
        }
        
        //select downstream
        evalSelections(children: children)
    }
    
    func setSelected() {
        
        selected = 1
        
        // Select upstream
        parent?.setSelected()
        
        guard let children = childrenNodes else {
            state = .selected
            return
        }
        
        //select downstream
        evalSelections(children: children)
    }
    
    func debugPrintSelections() {
        print("\(title) \(state) \(level) \(index)")
        childrenNodes?.forEach {
            $0.debugPrintSelections()
        }
    }
    
    private func evalSelections() {
        if let children = self.childrenNodes {
            let sum = children.reduce(0, { (result, node) -> Int in
                result + node.selected
            })
            
            switch sum {
            case 0:
                state = .none
            case children.count:
                state = .selected
            default:
                state = .indeterminate
            }
        }
    }
    
    private func evalSelections(children: [Node]) {
        
        let sum = children.reduce(0, { (result, node) -> Int in
            result + node.selected
        })
        
        switch sum {
        case 0:
            state = .none
        case children.count:
            state = .selected
        default:
            state = .indeterminate
        }
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        return "\(title): \(String(describing: childrenNodes?.count))"
    }
}
