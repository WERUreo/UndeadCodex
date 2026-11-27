import Testing
@testable import UndeadCodex

@Test
func formatsItemWithLocalizedName() {
    let item = Item(
        name: "ammo9mmBulletBall",
        properties: [:]
    )

    let formatter = ItemFormatter()

    let output = formatter.format(
        item,
        localizedName: "9mm Ammo"
    )

    #expect(output == "9mm Ammo (ammo9mmBulletBall)")
}

@Test
func formatsItemProperties() {
    let item = Item(
        name: "ammo9mmBulletBall",
        properties: [
            "Stacknumber": "300",
            "Material": "Mmetal"
        ]
    )

    let formatter = ItemFormatter()

    let output = formatter.format(
        item,
        localizedName: "9mm Ammo"
    )

    let expected = """
    9mm Ammo (ammo9mmBulletBall)

    Properties:
      Material: Mmetal
      Stacknumber: 300
    """

    #expect(output == expected)
}