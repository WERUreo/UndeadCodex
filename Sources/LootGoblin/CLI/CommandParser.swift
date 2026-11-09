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
}