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

    var configURL: URL {
        rootURL
            .appendingPathComponent("Data")
            .appendingPathComponent("Config")
    }

    var itemsURL: URL {
        configURL.appendingPathComponent("items.xml")
    }

    var blocksURL: URL {
        configURL.appendingPathComponent("blocks.xml")
    }

    var localizationURL: URL? {
        let csvURL = configURL.appendingPathComponent("Localization.csv")
        let txtURL = configURL.appendingPathComponent("Localization.txt")

        if FileManager.default.fileExists(atPath: csvURL.path) {
            return csvURL
        }

        if FileManager.default.fileExists(atPath: txtURL.path) {
            return txtURL
        }

        return nil
    }

    var modsURL: URL {
        rootURL.appendingPathComponent("Mods")
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
