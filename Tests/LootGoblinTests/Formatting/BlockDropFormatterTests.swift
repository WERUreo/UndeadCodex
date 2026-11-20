import Testing
@testable import LootGoblin

@Test
func formatsBlockDropMatch() {
    let block = Block(
        name: "testBlock",
        parentName: nil,
        drops: [
            Block.Drop(
                event: .harvest,
                itemName: "resourceWood",
                count: "2,5"
            )
        ],
        dropExtendsOff: false
    )

    let match = BlockDropMatch(
        block: block,
        drops: block.drops
    )

    let formatter = BlockDropFormatter(
        localization: LocalizationCatalog(entries: [])
    )

    let output = formatter.format(match)

    #expect(output == """
    testBlock
      Harvest: resourceWood (count: 2,5)
    """)
}