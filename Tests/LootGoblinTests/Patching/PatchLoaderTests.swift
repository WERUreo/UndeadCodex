import Testing
import Foundation
@testable import LootGoblin

@Test func loadsSetPatchXPath() throws {
    let url = try fixtureURL(named: "valid-set")
    let patch: SetPatch = try #require(PatchLoader().loadSetPatches(from: url).first)
    #expect(patch.xpath == "/items/item[@name='testItem']")
    
}

@Test func loadsValueSetPayload() throws {
    let url = try fixtureURL(named: "valid-set")
    let patch: SetPatch = try #require(PatchLoader().loadSetPatches(from: url).first)
    #expect(patch.payload == .value("testValue"))
}

@Test func loadsElementSetPayload() throws {
    let url = try fixtureURL(named: "structural-set")
    let patch: SetPatch = try #require(PatchLoader().loadSetPatches(from: url).first)
    
    guard case .elements(let elements) = patch.payload else {
        Issue.record("Expected elements payload")
        return
    }

    #expect(elements.count == 2)
}

@Test func throwsForMissingXPath() throws {
    let url = try fixtureURL(named: "missing-xpath")    
    #expect(throws: PatchLoaderError.missingXPath) {
        try PatchLoader().loadSetPatches(from: url)
    }
}

@Test func throwsForEmptyXPath() throws {
    let url = try fixtureURL(named: "empty-xpath")
    #expect(throws: PatchLoaderError.missingXPath) {
        try PatchLoader().loadSetPatches(from: url)
    }
}