struct LocalizationCatalog {
    let entries: [LocalizationEntry]

    func name(for key: String) -> String? {
        entries.first { $0.key == key }?.english
    }

    func key(for localizedName: String) -> String? {
        entries.first {
            $0.english.caseInsensitiveCompare(localizedName) == .orderedSame
        }?.key
    }
}