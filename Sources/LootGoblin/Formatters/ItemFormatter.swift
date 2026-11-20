struct ItemFormatter {
    func format(_ item: Item, localizedName: String?) -> String {
        var output: String
        if let localizedName {
            output = "\(localizedName) (\(item.name))"
        } else {
            output = item.name
        }

        guard !item.properties.isEmpty else {
            return output
        }

        let sortedProperties = item.properties.sorted { $0.key < $1.key }

        output += "\n\nProperties:"

        for (key, value) in sortedProperties {
            output += "\n  \(key): \(value)"
        }

        return output
    }
}