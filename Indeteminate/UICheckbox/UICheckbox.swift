//
//  UICheckbox.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import UIKit
import Combine

/// Table view sections ids
enum Section: CaseIterable {
    case primary
    case secondary
}

/// The states of the child node visibility
enum ChildVisibility {
    case collapsed
    case expand
}

/// This view is easy to setup. Just pass an array of dictionary of types
/// that conforms to a few protocols then you are set.
class UICheckbox<T>: UIView, UITableViewDelegate where T: Labelable {

    var checkBoxItemStyle: CheckBoxStyle = DefaultCheckboxStyle()
    
    var selectionObserver = PassthroughSubject<Row, Never>()
    
    var state: ChildVisibility = .collapsed
    
    private(set) var allRowModels: [Row] = []
    
    private var list: MultiLevelList<T>!
    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Row>! = nil
    private var store = Set<AnyCancellable>()
    private var root:  Row!
    
    init(rootItem title: String, items: [String:[T]]) {
        
        super.init(frame: .zero)
        
        root = Row(title: title, aClass: RootCheckBoxItemTableViewCell.self)
        
        fillItems(items: items)
        
        list = MultiLevelList(root: root, list: allRowModels)
    }
    
    func embedInContainer(container: UIView) {
        
        container.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            self.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
            self.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ]
        
        [constraints]
            .forEach(NSLayoutConstraint.activate(_:))
        
        addTableView()
        registerCells()
        self.dataSource = self.dataSource(tableView: tableView)
        updateTable()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTableView()
        registerCells()
    }
    
    private func fillItems(items: [String:[T]]) {
        
        for dict in items {
                  
        let key = dict.key
          
            let row = Row(title: key, aClass: ParentCheckboxItemTableViewCell.self, referenceValue: key)
            
            row.children = dict.value.map { node in
                let row = Row(title: node.title, aClass: ChildCheckBoxItemTableViewCell.self, referenceValue: dict.value)
                
                return row
            }
            allRowModels.append(row)
        }
    }
    
    private func addTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(tableView)
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ]
        
        [constraints]
            .forEach(NSLayoutConstraint.activate(_:))
    }
    
    private func registerCells() {
        tableView.register(aClass: ParentCheckboxItemTableViewCell.self)
        tableView.register(aClass: ChildCheckBoxItemTableViewCell.self)
        tableView.register(aClass: RootCheckBoxItemTableViewCell.self)
    }
    
    private func dataSource(tableView: UITableView) -> UITableViewDiffableDataSource<Section, Row> {
        let dataSource = UITableViewDiffableDataSource<Section, Row>(tableView: tableView, cellProvider: { (tableView, indexpath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier, for: indexpath)
            cell.rowModel = item
            cell.rowStyle = self.checkBoxItemStyle
            return cell
        })
    
        return dataSource
    }
    
    private func updateTable(animated: Bool = false) {
        
        let sections: [Section] = [.primary, .secondary]
        let sectionData: [Section: [Row]] = [.primary: [root], .secondary: allRowModels]
        
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        currentSnapshot.appendSections(sections)
        
        sections.forEach { section in
            let items = sectionData[section]
            currentSnapshot.appendItems(items!, toSection: section)
        }
        
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleVisibility(at: indexPath)
    }
    
    private func inserRows(_ children: [Row], _ callingField: Row) {
        currentSnapshot.insertItems(children, afterItem: callingField)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    private func removeRows(_ children: [Row]) {
        currentSnapshot.deleteItems(children)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    fileprivate func showChildren(_ allRows: [Row]) {
        allRows
            .filter {
                $0.state == .collapsed
            }
            .forEach { (row) in
                guard let children = row.children else {
                    return
                }
            
                row.state = .expand
                inserRows(children, row)
        }
    }
    
    fileprivate func hideChildren(_ allRows: [Row]) {
        allRows.forEach { (row) in
            guard let children = row.children else {
                return
            }
            row.state = .collapsed
            removeRows(children)
        }
    }
    
    private func toggleVisibility(at indexPath: IndexPath) {
        
        guard let callingField = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        if callingField == root {
            let allRows = dataSource.snapshot().itemIdentifiers
            
            if callingField.state == .expand {
                callingField.state = .collapsed
                
                hideChildren(allRows)
            } else if callingField.state == .collapsed {
                callingField.state = .expand
                
                showChildren(allRows)
            }
            
            return
        }
        
        guard let children = callingField.children else {
            return
        }

        if callingField.state == .expand {
            callingField.state = .collapsed
            removeRows(children)
            return
        }
        
        if callingField.state == .collapsed {
            callingField.state = .expand
            inserRows(children, callingField)
        }
    }
}
