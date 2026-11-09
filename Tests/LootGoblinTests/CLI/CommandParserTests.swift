import Testing
@testable import LootGoblin

@Test
func parsesInspectCommand() throws {
    let parser = CommandParser()

    let command = try parser.parse([
        "inspect",
        "ammo9mmBulletBall"
    ])

    #expect(command == .inspect("ammo9mmBulletBall"))
}

@Test
func parsesSearchCommand() throws {
    let parser = CommandParser()

    let command = try parser.parse([
        "search",
        "9mm"
    ])

    #expect(command == .search("9mm"))
}

@Test
func throwsWhenInspectArgumentIsMissing() {
    let parser = CommandParser()

    #expect(throws: CommandParserError.missingArgument) {
        try parser.parse(["inspect"])
    }
}

@Test
func throwsForUnknownCommand() {
    let parser = CommandParser()

    #expect(throws: CommandParserError.unknownCommand) {
        try parser.parse(["banana", "9mm"])
    }
}

@Test
func throwsForUnexpectedArguments() {
    let parser = CommandParser()

    #expect(throws: CommandParserError.unexpectedArgument) {
        try parser.parse([
            "inspect",
            "ammo9mBulletBall",
            "banana"
        ])
    }
}

@Test
func throwsWhenCommandIsMissing() {
    let parser = CommandParser()

    #expect(throws: CommandParserError.missingCommand) {
        try parser.parse([])
    }
}

@Test
func parsesBlockDropQuery() throws {
    let command = try CommandParser().parse([
        "blocks",
        "--drops",
        "resourceMechanicalParts"
    ])

    #expect(command == .blocksDropping("resourceMechanicalParts"))
}