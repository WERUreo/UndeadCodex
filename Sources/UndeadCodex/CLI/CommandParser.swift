enum CommandParserError: Error, Equatable {
    case missingArgument
    case missingCommand
    case unknownCommand
    case unexpectedArgument
}

struct CommandParser {
    func parse(_ arguments: [String]) throws -> LootCommand {
        guard let command = arguments.first else {
            throw CommandParserError.missingCommand
        }

        switch command {
        case "inspect", "search":
            guard arguments.count >= 2 else {
                throw CommandParserError.missingArgument
            }

            guard arguments.count == 2 else {
                throw CommandParserError.unexpectedArgument
            }

            return command == "inspect"
                ? .inspect(arguments[1])
                : .search(arguments[1])
        case "blocks":
            guard arguments.count >= 3 else {
                throw CommandParserError.missingArgument
            }

            guard arguments.count == 3 else {
                throw CommandParserError.unexpectedArgument
            }

            guard arguments[1] == "--drops" else {
                throw CommandParserError.unexpectedArgument
            }

            return .blocksDropping(arguments[2])
        default:
            throw CommandParserError.unknownCommand
        }
    }

    func parseOptions(_ arguments: [String]) throws -> CLIOptions {
        guard arguments.first == "--mod" else {
            return CLIOptions(
                modName: nil,
                command: try parse(arguments)
            )
        }

        guard arguments.count >= 2 else {
            throw CommandParserError.missingArgument
        }

        let modName = arguments[1]

        let command = try parse(
            Array(arguments.dropFirst(2))
        )

        return CLIOptions(
            modName: modName,
            command: command
        )
    }
}