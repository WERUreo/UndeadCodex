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
}