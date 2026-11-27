import Testing
@testable import UndeadCodex

@Test
func resolvesLocalizedBlockName() {
    let entries = [
        LocalizationEntry(
            key: "cntgasRangeWhite",
            file: "blocks",
            type: "Block",
            english: "White Gas Range"
        )
    ]

    let catalog = LocalizationCatalog(entries: entries)

    #expect(
        catalog.name(for: "cntgasRangeWhite") == "White Gas Range"
    )
}

@Test
func modLocalizationOverridesVanillaLocalization() {
    let vanilla = [
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        )
    ]

    let mod = [
        LocalizationEntry(
            key: "resourceWood",
            file: "",
            type: "",
            english: "Timber"
        )
    ]

    let catalog = LocalizationCatalog(
        entries: vanilla,
        patches: mod
    )

    #expect(catalog.entries.count == 1)
    #expect(catalog.name(for: "resourceWood") == "Timber")
    #expect(catalog.key(for: "Timber") == "resourceWood")
    #expect(catalog.key(for: "Wood") == nil)
}

@Test
func modLocalizationIntroducesNewKeys() {
    let vanilla = [
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        )
    ]

    let mod = [
        LocalizationEntry(
            key: "ulmResourceScrapTitanium",
            file: "",
            type: "",
            english: "Scrap Titanium"
        )
    ]

    let catalog = LocalizationCatalog(
        entries: vanilla,
        patches: mod
    )

    #expect(catalog.entries.count == 2)
    #expect(catalog.name(for: "resourceWood") == "Wood")
    #expect(catalog.name(for: "ulmResourceScrapTitanium") == "Scrap Titanium")
    #expect(catalog.key(for: "Scrap Titanium") == "ulmResourceScrapTitanium")
}

@Test
func emptyModTranslationPreservesVanillaTranslation() {
    let vanilla = [
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        )
    ]

    let mod = [
        LocalizationEntry(
            key: "resourceWood",
            file: "",
            type: "",
            english: ""
        )
    ]

    let catalog = LocalizationCatalog(
        entries: vanilla,
        patches: mod
    )

    #expect(catalog.entries.count == 1)
    #expect(catalog.name(for: "resourceWood") == "Wood")
    #expect(catalog.key(for: "Wood") == "resourceWood")
}

@Test
func modLocalizationOverridesKeysCaseInsensitively() {
    let vanilla = [
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        )
    ]

    let mod = [
        LocalizationEntry(
            key: "ResourceWood",
            file: "",
            type: "",
            english: "Timber"
        )
    ]

    let catalog = LocalizationCatalog(
        entries: vanilla,
        patches: mod
    )

    #expect(catalog.entries.count == 1)
    #expect(catalog.name(for: "resourceWood") == "Timber")
    #expect(catalog.key(for: "Timber") == "resourceWood")
    #expect(catalog.key(for: "Wood") == nil)
}

@Test
func modLocalizationPreservesExistingMetadata() {
    let vanilla = [
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        )
    ]

    let mod = [
        LocalizationEntry(
            key: "resourceWood",
            file: "",
            type: "",
            english: "Timber"
        )
    ]

    let catalog = LocalizationCatalog(
        entries: vanilla,
        patches: mod
    )

    #expect(catalog.entries.count == 1)
    #expect(catalog.entries.first?.file == "items")
    #expect(catalog.entries.first?.type == "Item")
    #expect(catalog.name(for: "resourceWood") == "Timber")
}

@Test
func duplicateVanillaLocalizationKeysPreserveFirstEntry() {
    let vanilla = [
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        ),
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Timber"
        )
    ]

    let catalog = LocalizationCatalog(entries: vanilla)

    #expect(catalog.entries.count == 1)
    #expect(catalog.name(for: "resourceWood") == "Wood")
    #expect(catalog.key(for: "Timber") == nil)
}

@Test
func emptyLocalizationTranslationIsUnavailable() {
    let mod = [
        LocalizationEntry(
            key: "ulmCustomResource",
            file: "",
            type: "",
            english: ""
        )
    ]

    let catalog = LocalizationCatalog(
        entries: [],
        patches: mod
    )

    #expect(catalog.entries.count == 1)
    #expect(catalog.name(for: "ulmCustomResource") == nil)
    #expect(catalog.key(for: "") == nil)
}

@Test
func localizationPatchesAreAppliedInOrder() {
    let vanilla = [
        LocalizationEntry(
            key: "resourceWood",
            file: "items",
            type: "Item",
            english: "Wood"
        )
    ]

    let patches = [
        LocalizationEntry(
            key: "resourceWood",
            file: "",
            type: "",
            english: "Timber"
        ),
        LocalizationEntry(
            key: "resourceWood",
            file: "",
            type: "",
            english: "Lumber"
        ),
        LocalizationEntry(
            key: "resourceWood",
            file: "",
            type: "",
            english: ""
        )
    ]

    let catalog = LocalizationCatalog(
        entries: vanilla,
        patches: patches
    )

    #expect(catalog.entries.count == 1)
    #expect(catalog.name(for: "resourceWood") == "Lumber")
    #expect(catalog.key(for: "Lumber") == "resourceWood")
    #expect(catalog.key(for: "Timber") == nil)
    #expect(catalog.key(for: "Wood") == nil)
}