import Foundation

struct ItemCatalog {
    let items: [Item]
    let localization: [LocalizationEntry]

    init(
        items: [Item],
        localization: [LocalizationEntry] = []
    ) {
        self.items = items
        self.localization = localization
    }

    func item(named name: String) -> Item? {
        items.first { $0.name == name }
    }

    func item(localizedName: String) -> Item? {
        guard let entry = localization.first(where: { $0.english == localizedName }) else {
            return nil
        }

        return item(named: entry.key)
    }

    func search(_ query: String) -> [ItemSearchResult] {
        items.compactMap { item in
            let entry = localization.first {
                $0.key == item.name
            }

            let internalNameMatches = item.name.localizedCaseInsensitiveContains(query)
            let localizedNameMatches = entry?.english.localizedCaseInsensitiveContains(query) ?? false

            guard internalNameMatches || localizedNameMatches else {
                return nil
            }

            return ItemSearchResult(
                item: item,
                localizedName: entry?.english
            )
        }
    }
}