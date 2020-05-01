//
//  CheckBoxItemTableViewCell.swift
//  Indeteminate
//
//  Created by Nazario Mariano on 4/28/20.
//  Copyright © 2020 Nazario Mariano. All rights reserved.
//

import UIKit
import Combine

class CheckBoxItemTableViewCell: UITableViewCell, FieldCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var style: CheckBoxStyle! {
        didSet {
            self.contentView.backgroundColor = style.defaultStyle()
            self.backgroundColorFor(model.currentState)
            button.isSelected = model.currentState == .selected
        }
    }
    
    var store = Set<AnyCancellable>()
    
    var model: Row! {
        didSet {
            model.stateReceiver
                .removeDuplicates()
                .sink { [weak self] (state) in
                self?.backgroundColorFor(state)
                self?.button.isSelected = state == .selected
            }.store(in: &store)
            
            self.label.text = model.title
        }
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        button.isSelected.toggle()
        model.selectReceiver = button.isSelected
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        store.removeAll()
    }
    
    private func backgroundColorFor(_ state: SelectionState) {
        switch state {
        case .indeterminate:
            self.contentView.backgroundColor = self.style.indeterminateStyle()
        case .none:
            self.contentView.backgroundColor = self.style.defaultStyle()
        case .selected:
            self.contentView.backgroundColor = self.style.selectedStyle()
        }
    }
}
