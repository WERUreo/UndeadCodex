import Testing
import Foundation
@testable import UndeadCodex

@Test
func loadsLocalizationEntries() throws {
    let url = try fixtureURL(
        named: "Localization",
        extension: "txt"
    )

    let entries = try LocalizationLoader().load(from: url)

    #expect(entries.count == 2)

    let ammo = try #require(
        entries.first { $0.key == "ammo9mmBulletBall" }
    )

    #expect(ammo.file == "items")
    #expect(ammo.type == "Ammo")
    #expect(ammo.english == "9mm Ammo")
}

@Test
func loadsLocalizationFrom3xFormat() throws {
    let url = try fixtureURL(
        named: "Localization",
        extension: "csv"
    )

    let entries = try LocalizationLoader().load(from: url)

    #expect(entries.count == 2)

    let ammo = try #require(
        entries.first { $0.key == "ammo9mmBulletBall" }
    )

    #expect(ammo.file == "items")
    #expect(ammo.type == "Ammo")
    #expect(ammo.english == "9mm Ammo")
}

@Test
func loadsUndeadLegacyLocalizationFormat() throws {
    let contents = "\u{FEFF}" + """
    Key,English

    campfireActivate,"Open Campfire"
    caffeineBuzz,"Caffeine Rush"
    caffeineBuzzDesc,"Caffeine gives you energy, keeping you warmer."
    """

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("txt")

    try contents.write(
        to: url,
        atomically: true,
        encoding: .utf8
    )

    defer {
        try? FileManager.default.removeItem(at: url)
    }

    let entries = try LocalizationLoader().load(from: url)

    #expect(entries.count == 3)

    #expect(
        entries.first {
            $0.key == "campfireActivate"
        }?.english == "Open Campfire"
    )

    #expect(
        entries.first {
            $0.key == "caffeineBuzzDesc"
        }?.english == "Caffeine gives you energy, keeping you warmer."
    )
}