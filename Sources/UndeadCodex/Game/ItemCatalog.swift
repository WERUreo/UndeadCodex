import Foundation

struct ItemCatalog {
    let items: [Item]
    let localization: [LocalizationEntry]

    private var localizationCatalog: LocalizationCatalog {
        LocalizationCatalog(entries: localization)
    }

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
        guard let key = localizationCatalog.key(for: localizedName) else {
            return nil
        }

        return item(named: key)
    }

    func localizedName(for item: Item) -> String? {
        localizationCatalog.name(for: item.name)
    }

    func search(_ query: String) -> [ItemSearchResult] {
        items.compactMap { item in
            let localizedName = localizedName(for: item)

            let internalNameMatches = item.name.localizedCaseInsensitiveContains(query)
            let localizedNameMatches = localizedName?.localizedCaseInsensitiveContains(query) ?? false

            guard internalNameMatches || localizedNameMatches else {
                return nil
            }

            return ItemSearchResult(
                item: item,
                localizedName: localizedName
            )
        }
    }
}