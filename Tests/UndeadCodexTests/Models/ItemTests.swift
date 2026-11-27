import Testing
import Foundation
@testable import UndeadCodex

@Test
func providesStackSize() {
    let item = Item(
        name: "testItem",
        properties: [
            "Stacknumber": "300"
        ]
    )

    #expect(item.stackSize == 300)
}

@Test
func providesMaterial() {
    let item = Item(
        name: "testItem",
        properties: [
            "Material": "Mbrass"
        ]
    )

    #expect(item.material == "Mbrass")
}

@Test
func providesEconomicValue() {
    let item = Item(
        name: "testItem",
        properties: [
            "EconomicValue": "9"
        ]
    )

    #expect(item.economicValue == 9)
}

@Test
func returnsNilForMissingProperties() {
    let item = Item(
        name: "testItem",
        properties: [:]
    )

    #expect(item.stackSize == nil)
    #expect(item.material == nil)
    #expect(item.economicValue == nil)
}

@Test
func returnsNilForInvalidNumericProperties() {
    let item = Item(
        name: "testItem",
        properties: [
            "Stacknumber": "not-a-number",
            "EconomicValue": "not-a-number"
        ]
    )

    #expect(item.stackSize == nil)
    #expect(item.economicValue == nil)
}