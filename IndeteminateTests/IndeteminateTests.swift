//
//  IndeteminateTests.swift
//  IndeteminateTests
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import XCTest
import Combine

@testable import Indeteminate

class IndeteminateTests: XCTestCase {

    
    override class func setUp() {
        
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func generateRows() -> (root: Row, children: [Row]) {
        let root = Row(id: "Root")
        
            let level1_1 = Row(id: "Level_1_1")
        
                let level2_1_1 = Row(id: "Level_2_1_1")
                let level2_1_2 = Row(id: "Level_2_1_2")
                let level2_1_3 = Row(id: "Level_2_1_3")
                
                    level1_1.children = [Row]()
                    level1_1.children?.append(level2_1_1)
                    level1_1.children?.append(level2_1_2)
                    level1_1.children?.append(level2_1_3)
        
            let level1_2 = Row(id: "Level_1_2")
        
                let level2_2_1 = Row(id: "Level_2_2_1")
                let level2_2_2 = Row(id: "Level_2_2_2")
                let level2_2_3 = Row(id: "Level_2_2_3")
                let level2_2_4 = Row(id: "Level_2_2_4")
        
                level1_2.children = [Row]()
                level1_2.children?.append(level2_2_1)
                level1_2.children?.append(level2_2_2)
                level1_2.children?.append(level2_2_3)
                level1_2.children?.append(level2_2_4)
        
            let level1_3 = Row(id: "Level_1_3")
        
                let level2_3_1 = Row(id: "Level_2_3_1")
                let level2_3_2 = Row(id: "Level_2_3_2")
                let level2_3_3 = Row(id: "Level_2_3_3")
        
                level1_3.children = [Row]()
                level1_3.children?.append(level2_3_1)
                level1_3.children?.append(level2_3_2)
                level1_3.children?.append(level2_3_3)

        
            root.children = [Row]()
            root.children?.append(level1_1)
            root.children?.append(level1_2)
            root.children?.append(level1_3)

        var rows = [Row]()
        rows.append(level1_1)
        rows.append(level1_2)
        rows.append(level1_3)
        
        return (root, rows)
    }
    
    func test_GivenData_Matches_Searched_NodeData() throws {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let level1_3 = Row(id: "Level_1_1")
        let nodeDataId = list.node(for: level1_3)?.data?.identifier
        
        XCTAssert( nodeDataId == "Level_1_1")
    }

    func test_GivenWrongDataIdentifier_DoesNotMatch_Found_NodeData() throws {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let level1_3 = Row(id: "Level_1_3")
        let nodeDataId = list.node(for: level1_3)?.data?.identifier
        
        XCTAssertNotNil(nodeDataId)
        XCTAssert( nodeDataId != "Level_1_1")
    }
    
    func test_AnotherGivenWrongDataIdentifier_DoesNotMatch_Found_NodeData() throws {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let row = Row(id: "Level_1_3")
        let nodeDataId = list.node(for: row)?.data?.identifier
        
        XCTAssertNotNil(nodeDataId)

        XCTAssertFalse(nodeDataId == "test")
    }
    
    // MARK: Second Level Child selections
    func test_SecondLevelParentIs_Selected_WhenAllChildrenAre_Selected() {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let parent = list.node(withID: "Level_1_1")

        XCTAssertNotNil(parent)
        
        let childNode_Level_2_1_1 = list.node(withID: "Level_2_1_1")
        let childNode_Level_2_1_2 = list.node(withID: "Level_2_1_2")
        let childNode_Level_2_1_3 = list.node(withID: "Level_2_1_3")
        
        XCTAssert(parent?.state == SelectionState.none)
        
        childNode_Level_2_1_1?.select(isSelected: true)
        childNode_Level_2_1_2?.select(isSelected: true)
        childNode_Level_2_1_3?.select(isSelected: true)
        
        XCTAssertFalse(parent?.state == SelectionState.none)
        XCTAssertFalse(parent?.state == SelectionState.indeterminate)
        XCTAssert(parent?.state == SelectionState.selected)
    }
    
    func test_SecondLevelParent_Indeterminate_WhenChildrenPartially_Selected() {
        
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let parent = list.node(withID: "Level_1_1")
        XCTAssertNotNil(parent)
        
        XCTAssert(parent?.data?.identifier == "Level_1_1")
        
        let parentRow = parent?.data as! Row

        XCTAssert(parentRow.identifier == "Level_1_1")
        
        let childNode_1 = list.node(withID: "Level_2_1_1")
        let childNode_2 = list.node(withID: "Level_2_1_2")
        let childNode_3 = list.node(withID: "Level_2_1_3")
        
        XCTAssert(parent?.state == SelectionState.none)
        
        childNode_1?.select(isSelected: false)
        childNode_2?.select(isSelected: true)
        childNode_3?.select(isSelected: true)
        
        XCTAssert(parent?.state == SelectionState.indeterminate)
      
    }
    
    func test_SecondLevelParent_Deselected_WhenAllChildrenAre_NotSelected() {
        //let level1_2 = Row(id: "Level_1_2")
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        let parent = list.node(withID: "Level_1_2")
        
        XCTAssertNotNil(parent)
        
        let childNode_1 = list.node(withID: "Level_2_2_1")
        let childNode_2 = list.node(withID: "Level_2_2_2")
        let childNode_3 = list.node(withID: "Level_2_2_3")
        let childNode_4 = list.node(withID: "Level_2_2_4")
        
        XCTAssertNotNil(childNode_1)
        XCTAssertNotNil(childNode_2)
        XCTAssertNotNil(childNode_3)
        XCTAssertNotNil(childNode_4)
        
        XCTAssert(parent?.state == SelectionState.none)
        
        childNode_1?.select(isSelected: false)
        childNode_2?.select(isSelected: false)
        childNode_3?.select(isSelected: false)
        childNode_4?.select(isSelected: false)
        
        XCTAssertFalse(parent?.state == SelectionState.indeterminate)
        XCTAssertFalse(parent?.state == SelectionState.selected)
        XCTAssert(parent?.state == SelectionState.none)
    }
    
    // MARK: Second Level Parent Selections
    func test_AllChildrenAre_Selected_When_SecondLevelParent_DirectlySelected() {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        let parent = list.node(withID: "Level_1_2")
        
        XCTAssertNotNil(parent)
        
        let childNode_1 = list.node(withID: "Level_2_2_1")
        let childNode_2 = list.node(withID: "Level_2_2_2")
        let childNode_3 = list.node(withID: "Level_2_2_3")
        let childNode_4 = list.node(withID: "Level_2_2_4")
        
        XCTAssertNotNil(childNode_1)
        XCTAssertNotNil(childNode_2)
        XCTAssertNotNil(childNode_3)
        XCTAssertNotNil(childNode_4)
        
        XCTAssert(parent?.state == SelectionState.none)
        
        parent?.select(isSelected: true)
        
        XCTAssert(childNode_1?.state == SelectionState.selected)
        XCTAssert(childNode_2?.state == SelectionState.selected)
        XCTAssert(childNode_3?.state == SelectionState.selected)
        XCTAssert(childNode_4?.state == SelectionState.selected)
        
        XCTAssertFalse(childNode_1?.state == SelectionState.indeterminate)
        XCTAssertFalse(childNode_2?.state == SelectionState.indeterminate)
        XCTAssertFalse(childNode_3?.state == SelectionState.indeterminate)
        XCTAssertFalse(childNode_4?.state == SelectionState.indeterminate)
        
        XCTAssertFalse(childNode_1?.state == SelectionState.none)
        XCTAssertFalse(childNode_2?.state == SelectionState.none)
        XCTAssertFalse(childNode_3?.state == SelectionState.none)
        XCTAssertFalse(childNode_4?.state == SelectionState.none)
    }
    
    func test_AllChildrenState_NotSelected_When_SecondLevelParent_DirectlyDeSelected() {
        let rows = generateRows()
         let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
         let parent = list.node(withID: "Level_1_2")
         
         XCTAssertNotNil(parent)
         
         let childNode_1 = list.node(withID: "Level_2_2_1")
         let childNode_2 = list.node(withID: "Level_2_2_2")
         let childNode_3 = list.node(withID: "Level_2_2_3")
         let childNode_4 = list.node(withID: "Level_2_2_4")
         
         XCTAssertNotNil(childNode_1)
         XCTAssertNotNil(childNode_2)
         XCTAssertNotNil(childNode_3)
         XCTAssertNotNil(childNode_4)
         
         XCTAssert(parent?.state == SelectionState.none)
         
         parent?.select(isSelected: true)
         
         XCTAssert(childNode_1?.state == SelectionState.selected)
         XCTAssert(childNode_2?.state == SelectionState.selected)
         XCTAssert(childNode_3?.state == SelectionState.selected)
         XCTAssert(childNode_4?.state == SelectionState.selected)
         
         XCTAssertFalse(childNode_1?.state == SelectionState.indeterminate)
         XCTAssertFalse(childNode_2?.state == SelectionState.indeterminate)
         XCTAssertFalse(childNode_3?.state == SelectionState.indeterminate)
         XCTAssertFalse(childNode_4?.state == SelectionState.indeterminate)
         
         XCTAssertFalse(childNode_1?.state == SelectionState.none)
         XCTAssertFalse(childNode_2?.state == SelectionState.none)
         XCTAssertFalse(childNode_3?.state == SelectionState.none)
         XCTAssertFalse(childNode_4?.state == SelectionState.none)
        
        parent?.select(isSelected: false)
        
        XCTAssert(childNode_1?.state == SelectionState.none)
        XCTAssert(childNode_2?.state == SelectionState.none)
        XCTAssert(childNode_3?.state == SelectionState.none)
        XCTAssert(childNode_4?.state == SelectionState.none)
        
        XCTAssertFalse(childNode_1?.state == SelectionState.indeterminate)
        XCTAssertFalse(childNode_2?.state == SelectionState.indeterminate)
        XCTAssertFalse(childNode_3?.state == SelectionState.indeterminate)
        XCTAssertFalse(childNode_4?.state == SelectionState.indeterminate)
        
        XCTAssertFalse(childNode_1?.state == SelectionState.selected)
        XCTAssertFalse(childNode_2?.state == SelectionState.selected)
        XCTAssertFalse(childNode_3?.state == SelectionState.selected)
        XCTAssertFalse(childNode_4?.state == SelectionState.selected)
    }

    // MARK: Root Level Selections
    func test_Root_DirectlySelected_AllNodes_Selected() {
        let rows = generateRows()
          let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
          let parent = list.node(withID: "Root")
          
          XCTAssertNotNil(parent)
          
        parent?.select(isSelected: true)
        
        for (index,node) in list.allItems().enumerated() {
            if index != 0 {
                XCTAssert(node.state == SelectionState.selected)
                XCTAssertFalse(node.state == SelectionState.indeterminate)
                XCTAssertFalse(node.state == SelectionState.none)
            }
        }
    }
    
    func test_Root_DirectlyDeSelected_AllNodes_DeSelected() {
        let rows = generateRows()
          let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
          let parent = list.node(withID: "Root")
          
          XCTAssertNotNil(parent)
          
        parent?.select(isSelected: false)
        
        for (index,node) in list.allItems().enumerated() {
            if index != 0 {
                XCTAssert(node.state == SelectionState.none)
                XCTAssertFalse(node.state == SelectionState.indeterminate)
                XCTAssertFalse(node.state == SelectionState.selected)
            }
        }
    }
    
    func test_Root_NotSelected_WhenAllChildren_NotSelected() {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let parent = list.node(withID: "Root")
          
        XCTAssertNotNil(parent)
        
        let child1 = list.node(withID: "Level_1_1")
        let child2 = list.node(withID: "Level_1_2")
        let child3 = list.node(withID: "Level_1_3")
        
        XCTAssertNotNil(child1)
        XCTAssertNotNil(child2)
        XCTAssertNotNil(child3)
        
        child1?.select(isSelected: false)
        child2?.select(isSelected: false)
        child3?.select(isSelected: false)
        
        XCTAssert(child1?.state == SelectionState.none)
        XCTAssert(child2?.state == SelectionState.none)
        XCTAssert(child3?.state == SelectionState.none)
        
        XCTAssertFalse(parent?.state == SelectionState.selected)
        XCTAssertFalse(parent?.state == SelectionState.indeterminate)
        XCTAssert(parent?.state == SelectionState.none)
    }
    
    func test_Root_Selected_When_AllChildren_Selected() {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let parent = list.node(withID: "Root")
          
        XCTAssertNotNil(parent)
        
        let child1 = list.node(withID: "Level_1_1")
        let child2 = list.node(withID: "Level_1_2")
        let child3 = list.node(withID: "Level_1_3")
        
        XCTAssertNotNil(child1)
        XCTAssertNotNil(child2)
        XCTAssertNotNil(child3)
        
        child1?.select(isSelected: true)
        child2?.select(isSelected: true)
        child3?.select(isSelected: true)
        
        XCTAssert(child1?.state == SelectionState.selected)
        XCTAssert(child2?.state == SelectionState.selected)
        XCTAssert(child3?.state == SelectionState.selected)
        
        XCTAssertFalse(parent?.state == SelectionState.none)
        XCTAssertFalse(parent?.state == SelectionState.indeterminate)
        XCTAssert(parent?.state == SelectionState.selected)
    }
    
    func test_RootState_Indeterminate_When_ChildrenAPartially_Selected() {
        let rows = generateRows()
        let list = MultiLevelList<Row>(root: rows.root, list: rows.children)
        
        let parent = list.node(withID: "Root")
          
        XCTAssertNotNil(parent)
        
        let child1 = list.node(withID: "Level_1_1")
        let child2 = list.node(withID: "Level_1_2")
        let child3 = list.node(withID: "Level_1_3")
        
        XCTAssertNotNil(child1)
        XCTAssertNotNil(child2)
        XCTAssertNotNil(child3)
        
        child1?.select(isSelected: false)
        child2?.select(isSelected: true)
        child3?.select(isSelected: true)
        
        XCTAssert(child1?.state == SelectionState.none)
        XCTAssert(child2?.state == SelectionState.selected)
        XCTAssert(child3?.state == SelectionState.selected)
        
        XCTAssertFalse(parent?.state == SelectionState.none)
        XCTAssertFalse(parent?.state == SelectionState.selected)
        XCTAssert(parent?.state == SelectionState.indeterminate)
    }
}
