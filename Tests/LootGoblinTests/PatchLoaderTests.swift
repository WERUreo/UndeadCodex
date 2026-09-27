import Testing
import Foundation
@testable import LootGoblin

@Test func loadsSetPatchXPath() throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "valid-set",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    let patch: SetPatch = try #require(PatchLoader().loadSetPatches(from: url).first)
    #expect(patch.xpath == "/items/item[@name='testItem']")
    
}

@Test func loadsValueSetPayload() throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "valid-set",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    let patch: SetPatch = try #require(PatchLoader().loadSetPatches(from: url).first)
    #expect(patch.payload == .value("testValue"))
}

@Test func loadsElementSetPayload() throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "structural-set",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    let patch: SetPatch = try #require(PatchLoader().loadSetPatches(from: url).first)
    #expect(patch.payload == .elements)
}

@Test func throwsForMissingXPath() throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "missing-xpath",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    #expect(throws: PatchLoaderError.missingXPath) {
        try PatchLoader().loadSetPatches(from: url)
    }
}

@Test func throwsForEmptyXPath() throws {
    let url = try #require(
        Bundle.module.url(
            forResource: "empty-xpath",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )

    #expect(throws: PatchLoaderError.missingXPath) {
        try PatchLoader().loadSetPatches(from: url)
    }
}