struct BlockDropFormatter {
    let localization: LocalizationCatalog

    func format(_ match: BlockDropMatch) -> String {
        let blockName = match.block.name

        let displayName: String

        if let localizedName = localization.name(for: blockName) {
            displayName = "\(localizedName) (\(blockName))"
        } else {
            displayName = blockName
        }

        var lines = [displayName]

        for drop in match.drops {
            let event = drop.event.rawValue.capitalized
            let itemName = drop.itemName ?? "Unknown"

            let localizedItemName = localization.name(for: itemName)

            let displayItemName: String

            if let localizedItemName {
                displayItemName = "\(localizedItemName) (\(itemName))"
            } else {
                displayItemName = itemName
            }

            lines.append(
                "  \(event): \(displayItemName) (count: \(drop.count))"
            )
        }

        return lines.joined(separator: "\n")
    }
}