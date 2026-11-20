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
            let options = try CommandParser().parseOptions(
                Array(CommandLine.arguments.dropFirst(2))
            )

            let installation = try GameInstallation(rootURL: gameURL)
            // print("Valid 7DTD installation found at \(installation.rootURL.path)")

            
            switch options.command {
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
                let catalog = try loadItemCatalog(from: installation)
                let localizationCatalog = LocalizationCatalog(entries: catalog.localization)

                let resolvedName = catalog.item(named: itemName)?.name
                    ?? catalog.item(localizedName: itemName)?.name
                    ?? itemName

                let blocks = try loadBlocks(
                    from: installation,
                    modName: options.modName
                )

                let matches = BlockQuery.matches(
                    dropping: resolvedName,
                    from: blocks
                )

                let formatter = BlockDropFormatter(
                    localization: localizationCatalog
                )

                for match in matches {
                    print(formatter.format(match))
                    print()
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

    static func loadBlocks(
        from installation: GameInstallation,
        modName: String? = nil
    ) throws -> [Block] {
        guard let modName else {
            let data = try Data(contentsOf: installation.blocksURL)
            return try BlockLoader.load(from: data)
        }

        let modDirectory = installation.rootURL
            .appendingPathComponent("Mods")
            .appendingPathComponent(modName)

        let document = try ModLoader.loadBlocks(
            gameDirectory: installation.rootURL,
            modDirectory: modDirectory
        )

        return try BlockLoader.load(from: document)
    }
}
