import Testing
import Foundation
@testable import LootGoblin

@Test 
func loadsElementName() throws {
    let url = try fixtureURL(named: "structural-set")
    let doc = try XMLDocument(contentsOf: url)
    let node = try #require(doc.nodes(matching: "//set").first)

    #expect(node.name == "set")
}

@Test
func loadsChildren() throws {
    let url = try fixtureURL(named: "structural-set")
    let doc = try XMLDocument(contentsOf: url)
    let node = try #require(doc.nodes(matching: "//set").first)

    #expect(node.children.count == 2)
    #expect(node.children[0].name == "property")
    #expect(node.children[1].name == "anotherProperty")
    #expect(node.children[1].children.count == 1)
    #expect(node.children[1].children[0].name == "nestedProperty")
}

@Test
func removesNodesMatchingXPath() throws {
    let xml = """
    <blocks>
        <block name="testBlock">
            <property name="UnlockedBy" value="perkTest" />
            <property name="Material" value="Mmetal" />
        </block>
    </blocks>
    """

    let document = try XMLDocument(data: Data(xml.utf8))

    try document.removeNodes(
        matching: "//property[@name='UnlockedBy']"
    )

    #expect(
        try document.countNodes(
            matching: "//property[@name='UnlockedBy']"
        ) == 0
    )

    #expect(
        try document.countNodes(
            matching: "//property[@name='Material']"
        ) == 1
    )
}

@Test
func removesOverlappingNodesSafely() throws {
    let xml = """
    <blocks>
        <block name="removeMe">
            <property name="Material" value="Mmetal"/>
        </block>
        <block name="keepMe">
            <property name="Material" value="Mwood"/>
        </block>
    </blocks>
    """

    let document = try XMLDocument(data: Data(xml.utf8))

    try document.removeNodes(
        matching: "//block[@name='removeMe'] | //block[@name='removeMe']/property"
    )

    #expect(
        try document.countNodes(matching: "//block[@name='removeMe']")
        == 0
    )

    #expect(
        try document.countNodes(matching: "//block[@name='keepMe']")
        == 1
    )

    #expect(
        try document.countNodes(matching: "//block[@name='keepMe']/property")
        == 1
    )
}