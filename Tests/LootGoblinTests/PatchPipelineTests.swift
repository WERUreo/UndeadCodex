import Testing
import Foundation
@testable import LootGoblin

@Test
func appliesLoadedSetPatches() throws {
    let targetURL = try fixtureURL(named: "multiple-set-target")
    let patchURL = try fixtureURL(named: "multiple-set-patches")
    
    let document = try XMLDocument(contentsOf: targetURL)
    let patches = try PatchLoader().loadSetPatches(from: patchURL)

    try PatchEngine().apply(patches, to: document)

    #expect(
        try document.countNodes(
            matching: "//property[@name='Material' and @value='matIron']"
        ) == 1
    )

    #expect(
        try document.countNodes(
            matching: "//property[@name='Stacknumber' and @value='500']"
        ) == 1
    )
}