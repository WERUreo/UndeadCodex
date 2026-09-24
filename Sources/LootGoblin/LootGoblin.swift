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

            let itemCount = try GameDataLoader().countItems(at: installation.itemsURL)
            print("Found \(itemCount) vanilla items.")

            let document = try XMLDocument(contentsOf: installation.itemsURL)
            let materialCount = try document.countNodes(matching: "//property[@name='Material' and @value='Mmetal']")
            print("Found \(materialCount) properties matching the UL Material patch")

            let beforeCount = try document.countNodes(
                matching: "//property[@name='Material' and @value='Mmetal']"
            )

            print("Mmetal before patch: \(beforeCount)")

            try document.setValue(
                matching: "//property[@name='Material' and @value='Mmetal']/@value",
                to: "matIron"
            )

            let afterCount = try document.countNodes(
                matching: "//property[@name='Material' and @value='Mmetal']"
            )

            print("Mmetal after patch: \(afterCount)")

        } catch {
            print("Error: \(error.localizedDescription)")
        }

    }
}
