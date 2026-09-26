import Testing
import Foundation
@testable import LootGoblin

@Test func missingXPath() async throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "missing-xpath",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    #expect(throws: PatchLoaderError.missingXPath) {
        try PatchLoader().loadSetNodes(from: url)
    }
}

@Test func xPathNoValue() async throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "xpath-novalue",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    #expect(throws: PatchLoaderError.missingXPath) {
        try PatchLoader().loadSetNodes(from: url)
    }
}

@Test func goodSetXPath() async throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "good-set-xpath",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    let nodes = try PatchLoader().loadSetNodes(from: url)
    #expect(nodes.count == 1)

    let node = try #require(nodes.first)
    #expect(node.attributes["xpath"] == "/items/item[@name='testItem']")    
}