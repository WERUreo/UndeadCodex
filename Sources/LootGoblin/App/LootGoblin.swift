import Foundation

@main
struct LootGoblin {
    static func main() {
        guard CommandLine.arguments.count > 2 else {
            print("Usage: LootGoblin <7DTD installation path> <search query>")
            return
        }

        let gameURL = URL(fileURLWithPath: CommandLine.arguments[1])
        let query = CommandLine.arguments[2]

        do {
            let installation = try GameInstallation(rootURL: gameURL)
            // print("Valid 7DTD installation found at \(installation.rootURL.path)")

            let items = try ItemLoader().loadItems(from: installation.itemsURL)
            // print("Found \(items.count) vanilla items.")

            let localization: [LocalizationEntry]

            if let localizationURL = installation.localizationURL {
                localization = try LocalizationLoader().load(from: localizationURL)
            } else {
                localization = []
            }

            let catalog = ItemCatalog(
                items: items,
                localization: localization
            )

            let results = catalog.search(query)

            for item in results {
                print(item.name)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
