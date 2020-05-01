//
//  Row.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import Foundation
import Combine

/// The class for caching all cell row state
class Row: ReuseIdentifier, Labelable {
    
    /// Receives binary selection state from the UI
    @Published var selectReceiver: Bool = false
    
    /// Subject that obserbes
    var stateReceiver = PassthroughSubject<SelectionState, Never>()
    
    /// Optional list of child rows
    var children: [Row]?
    
    /// ID for the cell
    var cellIdentifier: String
    
    /// A cache that refers to if the child rows are visible or not
    var state: ChildVisibility = .collapsed
   
    /// Row label
    var title: String
    
    private weak var weakNode: Node?
    var identifier = UUID().uuidString
    private(set) var currentState: SelectionState = .none
    fileprivate var store = Set<AnyCancellable>()
    fileprivate var referenceValue: Any?
    
    /// Row's primary initializer
    /// - Parameter title: The title text of the row
    /// - Parameter aClass: The tableview cell class for this row
    /// - Parameter referenceValue: The reference inbound value. It will be sent to the receiver
    /// when the row is selected
    init<T>(title: String, aClass: T.Type = T.self, referenceValue: Any? = nil) {
        self.cellIdentifier = String(describing: aClass)
        self.title = title
        self.referenceValue = referenceValue
    }
    
    /// Alternative initializer which can be useful when testing
    /// - Parameter id: An id and tile for this row
    init(id: String) {
        self.title = id
        self.identifier = id
        self.cellIdentifier = ""
        self.referenceValue = nil
    }
}

extension Row: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Row: CustomStringConvertible {
    var description: String {
        return "\(title) \(currentState))"
    }
}

/// Conforms to the `SelectionReceiver` protocol
extension Row: SelectionReceiver {
    var debugDescription: String? {
        return title
    }
    
    func link(node: Node) {
        
        // Set a weak reference
        self.weakNode = node
        
        // Bind
        $selectReceiver.sink { (isSelected) in
            self.weakNode?.select(isSelected: isSelected)
        }
        .store(in: &store)
    }
    
    func childNodes() -> [SelectionReceiver]? {
        self.children
    }
    
    func didChange(state: SelectionState) {
        self.currentState = state
        self.stateReceiver.send(state)
    }
}
