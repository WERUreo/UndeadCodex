struct ItemCatalog {
    let items: [Item]

    func item(named name: String) -> Item? {
        items.first { $0.name == name }
    }
}