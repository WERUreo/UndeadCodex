import Testing
import Foundation
@testable import LootGoblin

@Test
func parsesSimpleRow() {
    let fields = CSVParser().parse(
        "ammo9mmBulletBall,items,Ammo,,,9mm Ammo"
    )

    #expect(
        fields == [
            "ammo9mmBulletBall",
            "items",
            "Ammo",
            "",
            "",
            "9mm Ammo"
        ]
    )
}

@Test
func parsesQuotedComma() {
    let fields = CSVParser().parse(
        #"modMeleeGunToolDecapitizerDesc,item_modifiers,mod,,x,"You weren't really using that limb anyway, did ya?""#
    )

    #expect(
        fields == [
            "modMeleeGunToolDecapitizerDesc",
            "item_modifiers",
            "mod",
            "",
            "x",
            "You weren't really using that limb anyway, did ya?"
        ]
    )
}

@Test
func parsesEscapedQuotes() {
    let fields = CSVParser().parse(
        #"house_modern_19,POI,POIName,,x,"The ""Broken Dreams"" house""#
    )

    #expect(
        fields == [
            "house_modern_19",
            "POI",
            "POIName",
            "",
            "x",
            #"The "Broken Dreams" house"#
        ]
    )
}