import Testing
import Foundation
@testable import UndeadCodex

@Test
func findsStandardGameConfig() throws {
    let (rootURL, configURL) = try makeGameInstallation()

    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let installation = try GameInstallation(rootURL: rootURL)

    #expect(installation.itemsURL == configURL.appendingPathComponent("items.xml"))
}

@Test
func findsCSVLocalizationFile() throws {
    let (rootURL, configURL) = try makeGameInstallation()

    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let localizationURL = configURL
        .appendingPathComponent("Localization.csv")

    _ = FileManager.default.createFile(
        atPath: localizationURL.path,
        contents: Data()
    )

    let installation = try GameInstallation(rootURL: rootURL)

    #expect(installation.localizationURL == localizationURL)
}

@Test
func findsTXTLocalizationFile() throws {
    let (rootURL, configURL) = try makeGameInstallation()

    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let localizationURL = configURL
        .appendingPathComponent("Localization.txt")
    
    _ = FileManager.default.createFile(
            atPath: localizationURL.path,
            contents: Data()
    )

    let installation = try GameInstallation(rootURL: rootURL)

    #expect(installation.localizationURL == localizationURL)
}

@Test
func returnsNilWhenLocalizationFileMissing() throws {
    let (rootURL, _) = try makeGameInstallation()

    defer {
        try? FileManager.default.removeItem(at: rootURL)
    }

    let installation = try GameInstallation(rootURL: rootURL)

    #expect(installation.localizationURL == nil)
}

private func makeGameInstallation() throws -> (rootURL: URL, configURL: URL) {
    let rootURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    let configURL = rootURL
        .appendingPathComponent("Data")
        .appendingPathComponent("Config")

    try FileManager.default.createDirectory(
        at: configURL,
        withIntermediateDirectories: true
    )

    _ = FileManager.default.createFile(
        atPath: configURL.appendingPathComponent("items.xml").path,
        contents: Data()
    )

    return (rootURL, configURL) 
}