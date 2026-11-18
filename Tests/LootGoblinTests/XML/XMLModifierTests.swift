import Foundation
import Testing
@testable import LootGoblin

@Test
func appliesRemoveModification() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="UnlockedBy" value="perkTest" />
            <property name="Material" value="Mmetal" />
        </block>
    </blocks>
    """

    let modXML = """
    <Subquake>
        <remove xpath="//property[@name='UnlockedBy']" />
    </Subquake>
    """

    let document = try XMLDocument(data: Data(vanillaXML.utf8))
    let modifications = try XMLDocument(data: Data(modXML.utf8))

    try XMLModifier().apply(modifications, to: document)

    #expect(
        try document.countNodes(matching: "//property[@name='UnlockedBy']")
        == 0
    )

    #expect(
        try document.countNodes(matching: "//property[@name='Material']")
        == 1
    )
}

@Test
func appliesMultipleRemoveModifications() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="UnlockedBy" value="perkTest"/>
            <property name="Material" value="Mmetal"/>
            <property name="Group" value="Building"/>
        </block>
    </blocks>
    """

    let modXML = """
    <Subquake>
        <remove xpath="//property[@name='UnlockedBy']"/>
        <remove xpath="//property[@name='Group']"/>
    </Subquake>
    """

    let document = try XMLDocument(data: Data(vanillaXML.utf8))
    let modifications = try XMLDocument(data: Data(modXML.utf8))

    try XMLModifier().apply(modifications, to: document)

    #expect(
        try document.countNodes(matching: "//property[@name='UnlockedBy']")
        == 0
    )

    #expect(
        try document.countNodes(matching: "//property[@name='Group']")
        == 0
    )

    #expect(
        try document.countNodes(matching: "//property[@name='Material']")
        == 1
    )
}

@Test
func appliesSetModificationToAttribute() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="Model" value="oldModel"/>
            <property name="Material" value="Mmetal"/>
        </block>
    </blocks>
    """

    let modXML = """
    <Subquake>
        <set xpath="/blocks/block[@name='testBlock']/property[@name='Model']/@value">newModel</set>
    </Subquake>
    """

    let document = try XMLDocument(data: Data(vanillaXML.utf8))
    let modifications = try XMLDocument(data: Data(modXML.utf8))

    try XMLModifier().apply(modifications, to: document)

    let model = try document.nodes(
        matching: "/blocks/block[@name='testBlock']/property[@name='Model']"
    ).first

    let material = try document.nodes(
        matching: "/blocks/block[@name='testBlock']/property[@name='Material']"
    ).first

    #expect(model?.attributes["value"] == "newModel")
    #expect(material?.attributes["value"] == "Mmetal")
}

@Test
func appliesSetModificationWithChildElements() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="Material" value="Mwood"/>
            <drop event="Harvest" name="resourceWood" count="5"/>
        </block>
    </blocks>
    """

    let modXML = """
    <Subquake>
        <set xpath="/blocks/block[@name='testBlock']">
            <property name="Material" value="Mmetal"/>
            <drop event="Harvest" name="resourceScrapIron" count="10"/>
        </set>
    </Subquake>
    """

    let document = try XMLDocument(data: Data(vanillaXML.utf8))
    let modifications = try XMLDocument(data: Data(modXML.utf8))

    try XMLModifier().apply(modifications, to: document)

    let block = try document.nodes(
        matching: "/blocks/block[@name='testBlock']"
    ).first

    #expect(block?.children.count == 2)

    #expect(
        block?.children.first?.attributes["value"] == "Mmetal"
    )

    #expect(
        block?.children.last?.attributes["name"] == "resourceScrapIron"
    )
}

@Test
func appliesModificationsFromIncludedFile() throws {
    try withTemporaryDirectory { directory in
        let mainPatchURL = directory.appendingPathComponent("blocks.xml")
        let includedPatchURL = directory.appendingPathComponent("crops.xml")

        let mainPatch = """
        <Subquake>
            <include filename="crops.xml"/>
        </Subquake>
        """

        let includedPatch = """
        <Subquake>
            <remove xpath="//property[@name='UnlockedBy']"/>
        </Subquake>
        """

        try Data(mainPatch.utf8).write(to: mainPatchURL)
        try Data(includedPatch.utf8).write(to: includedPatchURL)

        let vanillaXML = """
        <blocks>
            <block name="testBlock">
                <property name="UnlockedBy" value="perkTest"/>
                <property name="Material" value="Mmetal"/>
            </block>
        </blocks>
        """

        let document = try XMLDocument(data: Data(vanillaXML.utf8))
        let modifications = try XMLDocument(contentsOf: mainPatchURL)

        try XMLModifier().apply(
            modifications,
            to: document,
            sourceURL: mainPatchURL
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
}

@Test
func appliesIncludedModificationsInOrder() throws {
    try withTemporaryDirectory { directory in
        let mainPatchURL = directory.appendingPathComponent("blocks.xml")
        let includedPatchURL = directory.appendingPathComponent("included.xml")

        let mainPatch = """
        <Subquake>
            <include filename="included.xml"/>
            <remove xpath="//property[@name='Material']"/>
        </Subquake>
        """

        let includedPatch = """
        <Subquake>
            <set xpath="/blocks/block[@name='testBlock']/property[@name='Material']/@value">Mmetal</set>
        </Subquake>
        """

        try Data(mainPatch.utf8).write(to: mainPatchURL)
        try Data(includedPatch.utf8).write(to: includedPatchURL)

        let vanillaXML = """
        <blocks>
            <block name ="testBlock">
                <property name="Material" value="Mwood"/>
            </block>
        </blocks>
        """

        let document = try XMLDocument(data: Data(vanillaXML.utf8))
        let modifications = try XMLDocument(contentsOf: mainPatchURL)

        try XMLModifier().apply(
            modifications,
            to: document,
            sourceURL: mainPatchURL
        )

        #expect(
            try document.countNodes(
                matching: "//property[@name='Material']"
            ) == 0
        )
    }
}

@Test
func appliesNestedIncludes() throws {
    try withTemporaryDirectory { directory in
        let mainPatchURL = directory
            .appendingPathComponent("blocks.xml")
        
        let cropsDirectory = directory
            .appendingPathComponent("Custom")

        let cropsPatchURL = cropsDirectory
            .appendingPathComponent("blocks_crops.xml")

        let nestedPatchURL = cropsDirectory
            .appendingPathComponent("crop_properties.xml")

        try FileManager.default.createDirectory(
            at: cropsDirectory,
            withIntermediateDirectories: true
        )

        let mainPatch = """
        <Subquake>
            <include filename="Custom/blocks_crops.xml"/>
        </Subquake>
        """

        let cropsPatch = """
        <Subquake>
            <include filename="crop_properties.xml"/>
        </Subquake>
        """

        let nestedPatch = """
        <Subquake>
            <remove xpath="//property[@name='UnlockedBy']"/>
        </Subquake>
        """

        try Data(mainPatch.utf8).write(to: mainPatchURL)
        try Data(cropsPatch.utf8).write(to: cropsPatchURL)
        try Data(nestedPatch.utf8).write(to: nestedPatchURL)

        let vanillaXML = """
        <blocks>
            <block name="testBlock">
                <property name="UnlockedBy" value="perkTest"/>
                <property name="Material" vaule="Mwood"/>
            </block>
        </blocks>
        """

        let document = try XMLDocument(
            data: Data(vanillaXML.utf8)
        )

        let modifications = try XMLDocument(
            contentsOf: mainPatchURL
        )

        try XMLModifier().apply(
            modifications,
            to: document,
            sourceURL: mainPatchURL
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
}

@Test
func rejectsCircularIncludes() throws {
    try withTemporaryDirectory { directory in
        let mainPatchURL = directory
            .appendingPathComponent("blocks.xml")

        let cropsPatchURL = directory
            .appendingPathComponent("crops.xml")

        let mainPatch = """
        <Subquake>
            <include filename="crops.xml"/>
        </Subquake>
        """

        let cropsPatch = """
        <Subquake>
            <include filename="blocks.xml"/>
        </Subquake>
        """

        try Data(mainPatch.utf8).write(to: mainPatchURL)
        try Data(cropsPatch.utf8).write(to: cropsPatchURL)

        let vanillaXML = """
        <blocks>
            <block name="testBlock"/>
        </blocks>
        """

        let document = try XMLDocument(
            data: Data(vanillaXML.utf8)
        )

        let modifications = try XMLDocument(
            contentsOf: mainPatchURL
        )

        #expect(throws: XMLModifierError.self) {
            try XMLModifier().apply(
                modifications,
                to: document,
                sourceURL: mainPatchURL
            )
        }
    }
}
@Test
func allowsRepeatedIncludes() throws {
    try withTemporaryDirectory { directory in
        let mainPatchURL = directory
            .appendingPathComponent("blocks.xml")

        let includedPatchURL = directory
            .appendingPathComponent("included.xml")

        let mainPatch = """
        <Subquake>
            <include filename="included.xml"/>
            <set xpath="/blocks/block[@name='testBlock']/property[@name='Material']/@value">Mwood</set>
            <include filename="included.xml"/>
        </Subquake>
        """

        let includedPatch = """
        <Subquake>
            <set xpath="/blocks/block[@name='testBlock']/property[@name='Material']/@value">Mmetal</set>
        </Subquake>
        """

        try Data(mainPatch.utf8).write(to: mainPatchURL)
        try Data(includedPatch.utf8).write(to: includedPatchURL)

        let vanillaXML = """
        <blocks>
            <block name="testBlock">
                <property name="Material" value="Mwood"/>
            </block>
        </blocks>
        """

        let document = try XMLDocument(
            data: Data(vanillaXML.utf8)
        )

        let modifications = try XMLDocument(
            contentsOf: mainPatchURL
        )

        try XMLModifier().apply(
            modifications,
            to: document,
            sourceURL: mainPatchURL
        )

        let properties = try document.nodes(
            matching: "//property[@name='Material']"
        )

        #expect(properties.count == 1)
        #expect(properties.first?.attributes["value"] == "Mmetal")
    }
}

@Test
func appliesUndeadLegacyBlockPatches() throws {
    let gameDirectory = URL(
        fileURLWithPath: "/mnt/c/Program Files (x86)/Steam/steamapps/common/7 Days To Die - Undead Legacy",
        isDirectory: true
    )

    let vanillaURL = gameDirectory
        .appendingPathComponent("Data/Config/blocks.xml")

    let modURL = gameDirectory
        .appendingPathComponent("Mods/UndeadLegacy/Config/blocks.xml")

    let document = try XMLDocument(contentsOf: vanillaURL)
    let modifications = try XMLDocument(contentsOf: modURL)

    try XMLModifier().apply(
        modifications,
        to: document,
        sourceURL: modURL
    )

    let blocks = try document.nodes(
        matching: "/blocks/block[@name='airConditioner']"
    )

    #expect(blocks.count == 1)

    let drops = try document.nodes(
        matching: """
        /blocks/block[@name='airConditioner']
        /drop[@event='Harvest'][@name='resourceElectricParts']
        """
    )

    #expect(drops.count == 1)
    #expect(drops.first?.attributes["count"] == "3,6")
}

@Test
func appliesAppendModificationToElement() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="Material" value="Mwood"/>
        </block>
    </blocks>
    """

    let patchXML = """
    <Subquake>
        <append xpath="/blocks/block[@name='testBlock']">
            <drop event="Harvest" name="resourceScrapIron" count="5"/>
            <drop event="Destroy" name="resourceScrapIron" count="2"/>
        </append>
    </Subquake>
    """

    let document = try XMLDocument(
        data: Data(vanillaXML.utf8)
    )

    let modifications = try XMLDocument(
        data: Data(patchXML.utf8)
    )

    try XMLModifier().apply(
        modifications,
        to: document
    )

    let blocks = try document.nodes(
        matching: "/blocks/block[@name='testBlock']"
    )

    #expect(blocks.count == 1)
    #expect(blocks.first?.children.count == 3)

    #expect(
        blocks.first?.children[0].attributes["name"] == "Material"
    )

    #expect(
        blocks.first?.children[1].attributes["event"] == "Harvest"
    )

    #expect(
        blocks.first?.children[2].attributes["event"] == "Destroy"
    )
}

@Test
func appliesInsertBeforeModification() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="Material" value="Mwood"/>
            <property name="EconomicValue" value="10"/>
        </block>
    </blocks>
    """

    let patchXML = """
    <Subquake>
        <insertBefore xpath="/blocks/block[@name='testBlock']/property[@name='EconomicValue']">
            <property name="Tags" value="test"/>
            <property name="DescriptionKey" value="testDescription"/>
        </insertBefore>
    </Subquake>
    """

    let document = try XMLDocument(
        data: Data(vanillaXML.utf8)
    )

    let modifications = try XMLDocument(
        data: Data(patchXML.utf8)
    )

    try XMLModifier().apply(
        modifications,
        to: document
    )

    let blocks = try document.nodes(
        matching: "/blocks/block[@name='testBlock']"
    )

    let propertyNames = blocks.first?.children.compactMap {
        $0.attributes["name"]
    }

    #expect(propertyNames == [
        "Material",
        "Tags",
        "DescriptionKey",
        "EconomicValue"
    ])
}

@Test
func appliesInsertAfterModification() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="Material" value="Mwood"/>
            <property name="EconomicValue" value="10"/>
        </block>
    </blocks>
    """

    let patchXML = """
    <Subquake>
        <insertAfter xpath="/blocks/block[@name='testBlock']/property[@name='Material']">
            <property name="Tags" value="test"/>
            <property name="DescriptionKey" value="testDescription"/>
        </insertAfter>
    </Subquake>
    """

    let document = try XMLDocument(
        data: Data(vanillaXML.utf8)
    )

    let modifications = try XMLDocument(
        data: Data(patchXML.utf8)
    )

    try XMLModifier().apply(
        modifications,
        to: document
    )

    let blocks = try document.nodes(
        matching: "/blocks/block[@name='testBlock']"
    )

    let propertyNames = blocks.first?.children.compactMap {
        $0.attributes["name"]
    }

    #expect(propertyNames == [
        "Material",
        "Tags",
        "DescriptionKey",
        "EconomicValue"
    ])
}

@Test
func appliesAppendModificationToAttribute() throws {
    let vanillaXML = """
    <blocks>
        <block name="testBlock">
            <property name="Tags" value="wood,flammable"/>
        </block>
    </blocks>
    """

    let patchXML = """
    <Subquake>
        <append xpath="/blocks/block[@name='testBlock']/property[@name='Tags']/@value">
            ,salvageable
        </append>
    </Subquake>
    """

    let document = try XMLDocument(
        data: Data(vanillaXML.utf8)
    )

    let modifications = try XMLDocument(
        data: Data(patchXML.utf8)
    )

    try XMLModifier().apply(
        modifications,
        to: document
    )

    let properties = try document.nodes(
        matching: "/blocks/block[@name='testBlock']/property[@name='Tags']"
    )

    #expect(properties.count == 1)
    #expect(
        properties.first?.attributes["value"] ==
        "wood,flammable,salvageable"
    )
}

private func withTemporaryDirectory(
    _ body: (URL) throws -> Void
) throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: true
    )

    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    try body(directory)
}

