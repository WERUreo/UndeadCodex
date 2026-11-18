import Foundation

enum ModLoader {
    static func loadBlocks(
        gameDirectory: URL,
        modDirectory: URL
    ) throws -> XMLDocument {
        let vanillaURL = gameDirectory
            .appendingPathComponent("Data/Config/blocks.xml")

        let patchURL = modDirectory
            .appendingPathComponent("Config/blocks.xml")

        let document = try XMLDocument(contentsOf: vanillaURL)
        let modifications = try XMLDocument(contentsOf: patchURL)

        try XMLModifier().apply(
            modifications,
            to: document,
            sourceURL: patchURL
        )

        return document
    }
}