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

@Test
func searchesItemsByLocalizedName() {
    let items = [
        Item(name: "firstItem", properties: [:]),
        Item(name: "secondItem", properties: [:]),
        Item(name: "resourceWood", properties: [:])
    ]

    let localization = [
        LocalizationEntry(
            key: "firstItem",
            file: "items",
            type: "Ammo",
            english: "9mm Ammo"
        ),
        LocalizationEntry(
            key: "secondItem",
            file: "items",
            type: "Ammo",
            english: ".44 Magnum Ammo"
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

    let results = catalog.search("ammo")

    #expect(results.count == 2)

    let firstResult = results.first {
        $0.item.name == "firstItem"
    }

    #expect(firstResult?.localizedName == "9mm Ammo")

    let secondResult = results.first {
        $0.item.name == "secondItem"
    }

    #expect(secondResult?.localizedName == ".44 Magnum Ammo")
}

@Test
func searchesItemsByInternalName() {
    let items = [
        Item(name: "ammo9mmBulletBall", properties: [:]),
        Item(name: "ammo44MagnumBulletBall", properties: [:]),
        Item(name: "resourceWood", properties: [:])
    ]

    let catalog = ItemCatalog(items: items)

    let results = catalog.search("ammo9mm")

    #expect(results.count == 1)
    #expect(results.first?.item.name == "ammo9mmBulletBall")
    #expect(results.first?.localizedName == nil)
}

@Test
func searchDoesNotReturnDuplicateItems() {
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

    let results = catalog.search("ammo")

    #expect(results.count == 1)
}

@Test
func findsLocalizedNameForItem() throws {
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
        catalog.item(named: "ammo9mmBulletBall")
    )

    #expect(catalog.localizedName(for: item) == "9mm Ammo")
}

@Test
func findsItemByLocalizedNameIgnoringCase() {
    let item = Item(
        name: "resourceMechanicalParts",
        properties: [:]
    )

    let localization = LocalizationEntry(
        key: "resourceMechanicalParts",
        file: "items",
        type: "item",
        english: "Mechanical Parts"
    )

    let catalog = ItemCatalog(
        items: [item],
        localization: [localization]
    )

    let result = catalog.item(localizedName: "mechanical parts")

    #expect(result?.name == "resourceMechanicalParts")
}