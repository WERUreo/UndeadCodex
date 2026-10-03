import Testing
import Foundation
@testable import LootGoblin

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