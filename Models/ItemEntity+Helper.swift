//
//  ItemEntity+Helper.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import Foundation

extension ItemEntity {
    var itemType: ItemType {
        get { ItemType(rawValue: type ?? "") ?? .journalType }
        set { type = newValue.rawValue }
    }
}
