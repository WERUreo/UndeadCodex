import Foundation

@main
struct LootGoblin {
    static func main() {
        guard CommandLine.arguments.count > 1 else {
            print("Usage: LootGoblin <7DTD installation path>")
            return
        }

        let gameURL = URL(fileURLWithPath: CommandLine.arguments[1])

        do {
            let installation = try GameInstallation(rootURL: gameURL)
            print("Valid 7DTD installation found at \(installation.rootURL.path)")

            let items = try ItemLoader().loadItems(from: installation.itemsURL)
            print("Found \(items.count) vanilla items.")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
