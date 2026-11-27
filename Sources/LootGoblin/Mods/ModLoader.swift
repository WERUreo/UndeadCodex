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

    static func loadLocalization(
        modDirectory: URL
    ) throws -> [LocalizationEntry] {
        let candidates = [
            modDirectory.appendingPathComponent(
                "Config/Localization.txt"
            ),
            modDirectory.appendingPathComponent(
                "Config/Localization/English.txt"
            )
        ]

        let loader = LocalizationLoader()
        var entries: [LocalizationEntry] = []

        for url in candidates {
            guard FileManager.default.fileExists(
                atPath: url.path
            ) else {
                continue
            }

            entries.append(
                contentsOf: try loader.load(from: url)
            )
        }

        return entries
    }
}