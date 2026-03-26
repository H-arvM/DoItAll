import Foundation

struct NoteGrouper {
    static func groupedByEntryID(_ items: [Item]) -> [(UUID?, [Item])] {
        let shoppingItems = items.filter { $0.shoppingEntryID != nil }
        let journalItems = items.filter { $0.shoppingEntryID == nil }

        let groupedShopping = Dictionary(grouping: shoppingItems, by: { $0.shoppingEntryID })
        let sortedShoppingGroups = groupedShopping.map { (key, value) in
            (key, value.sorted { ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast) })
        }
        let sortedShoppingByBatchDate = sortedShoppingGroups.sorted {
            ($0.1.last?.timestamp ?? .distantPast) > ($1.1.last?.timestamp ?? .distantPast)
        }
        let journalGroups = journalItems
            .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
            .map { (nil as UUID?, [$0]) }

        return sortedShoppingByBatchDate + journalGroups
    }
}
