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
class Row: ReuseIdentifier {
    
    @Published var selectReceiver: Bool = false
    @Published var isSelected: Bool = false
    
    var cellIdentifier: String
    var state: ChildVisibility = .collapsed
    var stateReceiver = PassthroughSubject<SelectionState, Never>()
    var children: [Row]?
    
    private(set) var identifier = UUID().uuidString
    private(set) var title: String
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
        bind()
    }
    
    fileprivate func bind() {
        self.stateReceiver.sink { (state) in
            self.currentState = state
            self.isSelected = state == .selected
        }
        .store(in: &store)
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
        return "\(title) \(isSelected) -> \(referenceValue ?? "")"
    }
}
