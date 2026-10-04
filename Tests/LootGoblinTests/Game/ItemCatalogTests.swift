import Testing
import Foundation
@testable import LootGoblin

@Test
func findsItemByName() throws {
    let items = [
        Item(name: "ammo9mmBulletBall", properties: [:]),
        Item(name: "resourceWood", properties: [:])
    ]

    let catalog = ItemCatalog(items: items)

    let item = try #require(
        catalog.item(named: "ammo9mmBulletBall")
    )

    #expect(item.name == "ammo9mmBulletBall")
}

@Test
func findsItemByLocalizedName() throws {
    let items = [
        Item(name: "ammo9mmBulletBall", properties: [:]),
        Item(name: "resourceWood", properties: [:])
    ]

    let localization = [
        LocalizationEntry(
            key: "ammo9mmBulletBall",
            file: "items",
            type: "Ammo",
            english: "9mm Ammo"
        ),
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Resource",
            english: "Wood"
        )
    ]

    let catalog = ItemCatalog(
        items: items,
        localization: localization
    )

    let item = try #require(
        catalog.item(localizedName: "9mm Ammo")
    )

    #expect(item.name == "ammo9mmBulletBall")
}

@Test
func returnsNilForUnknownLocalizedName() {
    let items = [
        Item(name: "ammo9mmBulletBall", properties: [:])
    ]

    let localization = [
        LocalizationEntry(
            key: "ammo9mmBulletBall",
            file: "items",
            type: "Ammo",
            english: "9mm Ammo"
        )
    ]

    let catalog = ItemCatalog(
        items: items,
        localization: localization
    )

    #expect(catalog.item(localizedName: "Banana Launcher") == nil)
}