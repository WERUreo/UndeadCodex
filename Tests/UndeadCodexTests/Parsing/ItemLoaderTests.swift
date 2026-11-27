import Testing
import Foundation
@testable import UndeadCodex

@Test
func loadsItem() throws {
    let url = try fixtureURL(named: "items")

    let items = try ItemLoader().loadItems(from: url)

    let item = try #require(
        items.first { $0.name == "testItem" }
    )

    #expect(item.name == "testItem")
    #expect(item.properties["Material"] == "Mmetal")
    #expect(item.properties["Stacknumber"] == "300")
    #expect(item.properties["EconomicValue"] == "9")
}

@Test
func loadsMultipleItems() throws {
    let url = try fixtureURL(named: "items")

    let items = try ItemLoader().loadItems(from: url)

    #expect(items.count == 2)
    #expect(items[0].name == "testItem")
    #expect(items[1].name == "secondItem")
}