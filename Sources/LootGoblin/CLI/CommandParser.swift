enum CommandParserError: Error, Equatable {
    case missingArgument
    case missingCommand
    case unknownCommand
    case unexpectedArgument
}

struct CommandParser {
    func parse(_ arguments: [String]) throws -> LootCommand {
        switch arguments.count {
        case 0:
            throw CommandParserError.missingCommand
        case 1:
            throw CommandParserError.missingArgument
        case 2:
            break
        default:
            throw CommandParserError.unexpectedArgument
        }

        switch arguments[0] {
        case "inspect":
            return .inspect(arguments[1])
        case "search":
            return .search(arguments[1])
        default:
            throw CommandParserError.unknownCommand
        }
    }
}