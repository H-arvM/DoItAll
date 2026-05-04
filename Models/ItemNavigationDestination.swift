//
//  ItemNavigationDestination.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/05/2026.
//

import Foundation
import CoreData

struct ItemNavigationDestination: Hashable {
    let itemID: NSManagedObjectID
    let itemType: ItemType
}
