import Foundation
import Testing
@testable import LootGoblin

@Test
func loadsSingleBlock() throws {
    let xml = """
    <blocks>
        <block name="woodShapes" />
    </blocks>
    """

    let data = Data(xml.utf8)
    let blocks = try BlockLoader.load(from: data)

    #expect(blocks.count == 1)
    #expect(blocks.first?.name == "woodShapes")
}

@Test
func loadsBlockHarvestDrop() throws {
    let xml = """
    <blocks>
        <block name="woodShapes">
            <drop event="Harvest" name="resourceWood" count="2" />
        </block>
    </blocks>
    """

    let blocks = try BlockLoader.load(from: Data(xml.utf8))

    let expectedDrop = Block.Drop(
        event: .harvest,
        itemName: "resourceWood",
        count: "2"
    )

    #expect(blocks.first?.drops == [expectedDrop])
}

@Test
func loadsMultipleBlocksFromFixture() throws {
    let url = try fixtureURL(named: "blocks")
    let data = try Data(contentsOf: url)

    let blocks = try BlockLoader.load(from: data)

    #expect(blocks.count == 2)
    #expect(blocks[0].name == "woodShapes")
    #expect(blocks[0].drops.count == 3)
    #expect(blocks[1].name == "stoneShapes")
    #expect(blocks[1].drops.count == 2)
    #expect(blocks[0].drops[1].itemName == nil)
    #expect(blocks[1].drops[0].count == "4,6")
}

@Test
func inheritsDropsFromParentBlock() throws {
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

    let blocks = try BlockLoader.load(from: Data(xml.utf8))

    let child = try #require(
        blocks.first { $0.name == "woodChild" }
    )

    #expect(child.drops == [
        Block.Drop(
            event: .harvest,
            itemName: "resourceWood",
            count: "2"
        )
    ])
}

@Test
func handlesCircularBlockInheritance() throws {
    let xml = """
    <blocks>
        <block name="woodA">
            <property name="Extends" value="woodB" />
            <drop event="Harvest" name="resourceWood" count="2" />
        </block>
        <block name="woodB">
            <property name="Extends" value="woodA" />
            <drop event="Harvest" name="resourceRockSmall" count="3" />
        </block>
    </blocks>
    """

    let blocks = try BlockLoader.load(from: Data(xml.utf8))

    let woodA = try #require(
        blocks.first { $0.name == "woodA" }
    )

    #expect(woodA.drops.count == 2)
    #expect(woodA.drops.contains {
        $0.itemName == "resourceWood"
    })
    #expect(woodA.drops.contains {
        $0.itemName == "resourceRockSmall"
    })
}

@Test
func reportsCircularBlockInheritance() throws {
    let xml = """
    <blocks>
        <block name="woodA">
            <property name="Extends" value="woodB" />
        </block>
        <block name="woodB">
            <property name="Extends" value="woodA" />
        </block>
    </blocks>
    """

    let result = try BlockLoader.loadWithDiagnostics(
        from: Data(xml.utf8)
    )

    #expect(result.blocks.count == 2)
    #expect(result.diagnostics.count == 1)
    #expect(result.diagnostics.first?.severity == .warning)
}