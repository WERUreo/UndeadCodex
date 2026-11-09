import Testing
@testable import LootGoblin

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