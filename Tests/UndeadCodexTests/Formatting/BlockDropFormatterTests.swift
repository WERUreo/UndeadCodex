import Testing
@testable import UndeadCodex

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

@Test
func formatsLocalizedBlockDropMatch() {
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

    let localization = LocalizationCatalog(entries: [
        LocalizationEntry(
            key: "testBlock",
            file: "blocks",
            type: "Block",
            english: "Test Block"
        ),
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        )
    ])

    let match = BlockDropMatch(
        block: block,
        drops: block.drops
    )

    let formatter = BlockDropFormatter(
        localization: localization
    )

    #expect(formatter.format(match) == """
    Test Block (testBlock)
      Harvest: Wood (resourceWood) (count: 2,5)
    """)
}