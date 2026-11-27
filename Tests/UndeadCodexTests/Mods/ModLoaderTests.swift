import Foundation
import Testing
@testable import UndeadCodex

@Test
func loadsBlocksWithSelectedMod() throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    let gameDirectory = directory.appendingPathComponent("Game")
    let modDirectory = gameDirectory.appendingPathComponent("Mods/TestMod")

    let configDirectory = gameDirectory.appendingPathComponent("Data/Config")
    let modConfigDirectory = modDirectory.appendingPathComponent("Config")

    try FileManager.default.createDirectory(
        at: configDirectory,
        withIntermediateDirectories: true
    )

    try FileManager.default.createDirectory(
        at: modConfigDirectory,
        withIntermediateDirectories: true
    )

    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <drop event="Harvest" name="resourceWood" count="1"/>
        </block>
    </blocks>
    """

    let patchXML = """
    <Subquake>
        <set xpath="/blocks/block[@name='testBlock']/drop/@count">3,6</set>
    </Subquake>
    """

    try Data(vanillaXML.utf8).write(
        to: configDirectory.appendingPathComponent("blocks.xml")
    )

    try Data(patchXML.utf8).write(
        to: modConfigDirectory.appendingPathComponent("blocks.xml")
    )

    let document = try ModLoader.loadBlocks(
        gameDirectory: gameDirectory,
        modDirectory: modDirectory
    )

    let drops = try document.nodes(
        matching: "/blocks/block[@name='testBlock']/drop"
    )

    #expect(drops.count == 1)
    #expect(drops.first?.attributes["count"] == "3,6")
}

@Test(
    .tags(.integration),
    .enabled(if: IntegrationTestConfiguration.undeadLegacyDirectory != nil)
)
func loadsUndeadLegacyBlocks() throws {
    let gameDirectory = try #require(
        IntegrationTestConfiguration.undeadLegacyDirectory
    )

    let modDirectory = gameDirectory
        .appendingPathComponent("Mods/UndeadLegacy")

    let document = try ModLoader.loadBlocks(
        gameDirectory: gameDirectory,
        modDirectory: modDirectory
    )

    let blocks = try BlockLoader.load(from: document)

    let airConditioner = try #require(
        blocks.first { $0.name == "airConditioner" }
    )

    let electricParts = try #require(
        airConditioner.drops.first {
            $0.event == .harvest &&
            $0.itemName == "resourceElectricParts"
        }
    )

    #expect(electricParts.count == "3,6")
}

@Test
func loadsModLocalization() throws {
    let modDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    let localizationDirectory = modDirectory
        .appendingPathComponent("Config/Localization")

    try FileManager.default.createDirectory(
        at: localizationDirectory,
        withIntermediateDirectories: true
    )

    defer {
        try? FileManager.default.removeItem(at: modDirectory)
    }

    let contents = """
    Key,English
    ulmResourceScrapTitanium,"Scrap Titanium"
    """

    try contents.write(
        to: localizationDirectory
            .appendingPathComponent("English.txt"),
        atomically: true,
        encoding: .utf8
    )

    let entries = try ModLoader.loadLocalization(
        modDirectory: modDirectory
    )

    #expect(entries.count == 1)
    #expect(entries.first?.key == "ulmResourceScrapTitanium")
    #expect(entries.first?.english == "Scrap Titanium")
}

@Test
func handlesMissingModLocalization() throws {
    let modDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    try FileManager.default.createDirectory(
        at: modDirectory,
        withIntermediateDirectories: true
    )

    defer {
        try? FileManager.default.removeItem(at: modDirectory)
    }

    let entries = try ModLoader.loadLocalization(
        modDirectory: modDirectory
    )

    #expect(entries.isEmpty)
}

@Test
func loadsConventionalModLocalization() throws {
    let modDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    let configDirectory = modDirectory
        .appendingPathComponent("Config")

    try FileManager.default.createDirectory(
        at: configDirectory,
        withIntermediateDirectories: true
    )

    defer {
        try? FileManager.default.removeItem(at: modDirectory)
    }

    let contents = """
    Key,File,Type,english
    customResource,items,Item,"Custom Resource"
    """

    try contents.write(
        to: configDirectory
            .appendingPathComponent("Localization.txt"),
        atomically: true,
        encoding: .utf8
    )

    let entries = try ModLoader.loadLocalization(
        modDirectory: modDirectory
    )

    #expect(entries.count == 1)
    #expect(entries.first?.key == "customResource")
    #expect(entries.first?.english == "Custom Resource")
    #expect(entries.first?.file == "items")
    #expect(entries.first?.type == "Item")
}

@Test
func loadsBothModLocalizationFormats() throws {
    let modDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    let configDirectory = modDirectory
        .appendingPathComponent("Config")

    let localizationDirectory = configDirectory
        .appendingPathComponent("Localization")

    try FileManager.default.createDirectory(
        at: localizationDirectory,
        withIntermediateDirectories: true
    )

    defer {
        try? FileManager.default.removeItem(at: modDirectory)
    }

    let conventionalContents = """
    Key,File,Type,english
    resourceWood,items,Item,"Timber"
    """

    let languageContents = """
    Key,English
    resourceWood,"Lumber"
    """

    try conventionalContents.write(
        to: configDirectory
            .appendingPathComponent("Localization.txt"),
        atomically: true,
        encoding: .utf8
    )

    try languageContents.write(
        to: localizationDirectory
            .appendingPathComponent("English.txt"),
        atomically: true,
        encoding: .utf8
    )

    let entries = try ModLoader.loadLocalization(
        modDirectory: modDirectory
    )

    #expect(entries.map(\.key) == [
        "resourceWood",
        "resourceWood"
    ])

    #expect(entries.map(\.english) == [
        "Timber",
        "Lumber"
    ])
}