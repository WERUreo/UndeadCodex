import Testing
import Foundation
@testable import LootGoblin

@Test
func findsBlocksDroppingHarvestResource() {
    let blocks = [
        Block(
            name: "cntStove",
            drops: [
                Block.Drop(
                    event: .harvest,
                    itemName: "resourceMechanicalParts",
                    count: "2"
                )
            ]
        ),
        Block(
            name: "cntFridge",
            drops: [
                Block.Drop(
                    event: .harvest,
                    itemName: "resourceScrapPolymers",
                    count: "3"
                )
            ]
        ),
        Block(
            name: "cntCar",
            drops: [
                Block.Drop(
                    event: .destroy,
                    itemName: "resourceMechanicalParts",
                    count: "1"
                )
            ]
        )
    ]

    let matches = BlockQuery.blocks(
        dropping: "resourceMechanicalParts",
        from: blocks
    )

    #expect(matches.map(\.name) == ["cntStove"])
}

@Test
func findsBlocksWithInheritedHarvestDrops() throws {
    let xml = """
    <blocks>
        <block name="woodBase">
            <drop event="Harvest" name="resourceWood" count="2" />
        </block>
        <block name="woodChild">
            <property name="Extends" value="woodBase" />
        </block>
    </blocks>
    """

    let blocks = try BlockLoader.load(
        from: Data(xml.utf8)
    )

    let matches = BlockQuery.blocks(
        dropping: "resourceWood",
        from: blocks
    )

    #expect(Set(matches.map(\.name)) == Set(["woodBase", "woodChild"]))
}