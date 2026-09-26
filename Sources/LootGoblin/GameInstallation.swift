import Foundation

enum GameInstallationError: LocalizedError {
    case invalidDirectory
    case missingConfig

    var errorDescription: String? {
        switch self {
        case .invalidDirectory:
            return "The specified path is not a valid directory."
        case .missingConfig:
            return "Could not find Data/Config/items.xml"
        }
    }
}

struct GameInstallation {
    let rootURL: URL

    var itemsURL: URL {
        rootURL
            .appendingPathComponent("Data")
            .appendingPathComponent("Config")
            .appendingPathComponent("items.xml")
    }

    var modsURL: URL {
        rootURL.appendingPathComponent("Mods")
    }

    // TODO: Remove this once we implement proper system
    var undeadLegacyItemsURL: URL {
        modsURL
            .appendingPathComponent("UndeadLegacy")
            .appendingPathComponent("Config")
            .appendingPathComponent("items.xml")
    }

    init(rootURL: URL) throws {
        var isDirectory: ObjCBool = false

        let exists = FileManager.default.fileExists(
            atPath: rootURL.path,
            isDirectory: &isDirectory
        )

        guard exists && isDirectory.boolValue else {
            throw GameInstallationError.invalidDirectory
        }

        self.rootURL = rootURL

        guard FileManager.default.fileExists(atPath: itemsURL.path) else {
            throw GameInstallationError.missingConfig
        }       
    }
}
