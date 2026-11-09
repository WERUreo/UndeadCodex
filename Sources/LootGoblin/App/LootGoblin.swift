import Foundation

@main
struct LootGoblin {
    static func main() {
        guard CommandLine.arguments.count > 1 else {
            print("Usage: LootGoblin <7DTD installation path> <search query>")
            return
        }

        let gameURL = URL(fileURLWithPath: CommandLine.arguments[1])

        do {
            let command = try CommandParser().parse(
                Array(CommandLine.arguments.dropFirst(2))
            )

            let installation = try GameInstallation(rootURL: gameURL)
            // print("Valid 7DTD installation found at \(installation.rootURL.path)")

            
            switch command {
            case .search(let query):
                let catalog = try loadItemCatalog(from: installation)
                let results = catalog.search(query)

                for result in results {
                    if let localizedName = result.localizedName {
                        print("\(localizedName) (\(result.item.name))")
                    } else {
                        print(result.item.name)
                    }
                }
            case .inspect(let itemName):
                let catalog = try loadItemCatalog(from: installation)
                if let item = catalog.item(named: itemName) {
                    let localizedName = catalog.localizedName(for: item)

                    let formatter = ItemFormatter()
                    print(formatter.format(item, localizedName: localizedName))
                } else {
                    print("Item not found: \(itemName)")
                }
            case .blocksDropping(let itemName):
                let data = try Data(contentsOf: installation.blocksURL)
                let blocks = try BlockLoader.load(from: data)

                let matches = BlockQuery.blocks(
                    dropping: itemName,
                    from: blocks
                )

                for block in matches {
                    print(block.name)
                }

                print("Found \(matches.count) matching blocks")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    static func loadItemCatalog(
        from installation: GameInstallation
    ) throws -> ItemCatalog {
        let items = try ItemLoader().loadItems(
            from: installation.itemsURL
        )

        let localization: [LocalizationEntry]

        if let localizationURL = installation.localizationURL {
            localization = try LocalizationLoader().load(
                from: localizationURL
            )
        } else {
            localization = []
        }

        return ItemCatalog(
            items: items,
            localization: localization
        )
    }
}
