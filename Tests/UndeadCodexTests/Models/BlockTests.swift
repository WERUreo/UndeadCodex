import Testing
@testable import UndeadCodex

@Test
func storesBlockName() {
    let block = Block(name: "woodShapes")

    #expect(block.name == "woodShapes")
}

@Test
func storesHarvestDrops() {
    let drop = Block.Drop(
        event: .harvest,
        itemName: "resourceWood",
        count: "2"
    )

    let block = Block(
        name: "woodShapes",
        drops: [drop]
    )

    #expect(block.drops == [drop])
}