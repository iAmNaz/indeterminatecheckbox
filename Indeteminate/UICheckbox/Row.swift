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
    var state: ChildVisibility = .collapsed
    var cellIdentifier: String
    var identifier = UUID().uuidString
    var title: String
    var children: [Row]?
    var stateReceiver = PassthroughSubject<SelectionState, Never>()
    var currentState: SelectionState = .none
    var store = Set<AnyCancellable>()
    
    @Published var selectReceiver: Bool = false
    @Published var isSelected: Bool = false
    
    init<T>(title: String, aClass: T.Type = T.self) {
        self.cellIdentifier = String(describing: aClass)
        self.title = title
        bind()
    }
    
    func bind() {
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
