import Testing
import Foundation
@testable import LootGoblin

@Test
func appliesValueSetPatch() throws {
    let url = try fixtureURL(named: "value-set-target")
    let document = try XMLDocument(contentsOf: url)

    let patch = SetPatch(
    xpath: "//property[@name='Material' and @value='Mmetal']/@value",
    payload: .value("matIron")
    )

    try PatchEngine().apply(patch, to: document)

    #expect(
        try document.countNodes(
            matching: "//property[@name='Material' and @value='matIron']"
        ) == 2
    )

    #expect(
        try document.countNodes(
            matching: "//property[@name='Material' and @value='Mmetal']"
        ) == 0
    )
}
