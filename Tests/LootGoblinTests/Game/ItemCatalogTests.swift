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