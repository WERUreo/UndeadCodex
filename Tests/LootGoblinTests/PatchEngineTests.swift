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

@Test
func appliesElementSetPatch() throws {
    let url = try fixtureURL(named: "element-set-target")
    print("Fixture URL: ", url.path)
    let document = try XMLDocument(contentsOf: url)

    let elements = [
        XMLNode(
            name: "property",
            attributes: [
                "name": "NewProperty1",
                "value": "newValue1"
            ],
            content: "",
            children: []
        ),
        XMLNode(
            name: "property",
            attributes: [
                "name": "NewProperty2",
                "value": "newValue2"
            ],
            content: "",
            children: []
        )
    ]

    let patch = SetPatch(
        xpath: "/items/item[@name='testItem']",
        payload: .elements(elements)
    )

    try PatchEngine().apply(patch, to: document)

    #expect(
        try document.countNodes(
            matching: "/items/item[@name='testItem']/property[@name='OldProperty1']"
        ) == 0
    )

    #expect(
        try document.countNodes(
            matching: "/items/item[@name='testItem']/property[@name='OldProperty2']"
        ) == 0
    )

    #expect(
        try document.countNodes(
            matching: "/items/item[@name='testItem']/property[@name='NewProperty1' and @value='newValue1']"
        ) == 1
    )

    #expect(
        try document.countNodes(
            matching: "/items/item[@name='testItem']/property[@name='NewProperty2' and @value='newValue2']"
        ) == 1
    )
}