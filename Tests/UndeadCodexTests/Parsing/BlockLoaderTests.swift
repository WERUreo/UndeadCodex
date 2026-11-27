import Foundation
import Testing
@testable import UndeadCodex

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

@Test
func doesNotDuplicateCircularInheritanceWarnings() throws {
    let xml = """
    <blocks>
        <block name="woodA">
            <property name="Extends" value="woodB" />
        </block>
        <block name="woodB">
            <property name="Extends" value="woodA" />
        </block>
        <block name="woodC">
            <property name="Extends" value="woodA" />
        </block>
    </blocks>
    """

    let result = try BlockLoader.loadWithDiagnostics(
        from: Data(xml.utf8)
    )

    #expect(result.blocks.count == 3)
    #expect(result.diagnostics.count == 1)
}

@Test
func reportsIndependentCircularInheritanceWarnings() throws {
    let xml = """
    <blocks>
        <block name="woodA">
            <property name="Extends" value="woodB" />
        </block>
        <block name="woodB">
            <property name="Extends" value="woodA" />
        </block>
        <block name="stoneA">
            <property name="Extends" value="stoneB" />
        </block>
        <block name="stoneB">
            <property name="Extends" value="stoneA" />
        </block>
    </blocks>
    """

    let result = try BlockLoader.loadWithDiagnostics(
        from: Data(xml.utf8)
    )

    #expect(result.blocks.count == 4)
    #expect(result.diagnostics.count == 2)
    #expect(result.diagnostics.allSatisfy {
        $0.severity == .warning
    })
}

@Test
func disablesInheritedDrops() throws {
    let xml = """
    <blocks>
        <block name="woodBase">
            <drop event="Harvest" name="resourceWood" count="2" />
        </block>
        <block name="woodChild">
            <property name="Extends" value="woodBase" />
            <dropextendsoff />
            <drop event="Harvest" name="resourceScrapIron" count="1" />
        </block>
    </blocks>
    """

    let blocks = try BlockLoader.load(from: Data(xml.utf8))
    let child = try #require(
        blocks.first { $0.name == "woodChild" }
    )

    #expect(child.drops.count == 1)
    #expect(child.drops.first?.itemName == "resourceScrapIron")
}

@Test
func stopsDropInheritanceAtIntermediateBlock() throws {
    let xml = """
    <blocks>
        <block name="woodBase">
            <drop event="Harvest" name="resourceWood" count="2" />
        </block>
        <block name="woodMiddle">
            <property name="Extends" value="woodBase" />
            <dropextendsoff />
            <drop event="Harvest" name="resourceScrapIron" count="1" />
        </block>
        <block name="woodChild">
            <property name="Extends" value="woodMiddle" />
        </block>
    </blocks>
    """

    let blocks = try BlockLoader.load(from: Data(xml.utf8))

    let child = try #require(
        blocks.first { $0.name == "woodChild" }
    )

    #expect(child.drops.count == 1)
    #expect(child.drops.first?.itemName == "resourceScrapIron")
}

@Test
func loadsBlocksFromPatchedXMLDocument() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <drop event="Harvest" name="resourceWood" count="1"/>
        </block>
    </blocks>
    """

    let patchXML = """
    <Subquake>
        <set xpath="/blocks/block[@name='testBlock']/drop[@name='resourceWood']/@count">3,6</set>
    </Subquake>
    """

    let document = try XMLDocument(data: Data(vanillaXML.utf8))
    let modifications = try XMLDocument(data: Data(patchXML.utf8))

    try XMLModifier().apply(modifications, to: document)

    let result = try BlockLoader.loadWithDiagnostics(from: document)

    let block = try #require(
        result.blocks.first { $0.name == "testBlock" }
    )

    let drop = try #require(
        block.drops.first { $0.itemName == "resourceWood" }
    )

    #expect(drop.count == "3,6")
}