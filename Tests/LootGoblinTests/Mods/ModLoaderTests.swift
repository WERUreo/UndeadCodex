import Foundation
import Testing
@testable import LootGoblin

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

@Test
func loadsUndeadLegacyBlocks() throws {
    let gameDirectory = URL(
        fileURLWithPath: "/mnt/c/Program Files (x86)/Steam/steamapps/common/7 Days To Die - Undead Legacy",
        isDirectory: true
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