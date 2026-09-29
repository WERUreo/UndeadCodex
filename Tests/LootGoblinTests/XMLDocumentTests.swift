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