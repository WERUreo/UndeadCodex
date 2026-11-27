import Foundation

enum IntegrationTestConfiguration {
    static var undeadLegacyPath: String? {
        guard let path = ProcessInfo.processInfo
            .environment["UNDEADCODEX_UL_PATH"],
            !path.isEmpty else {
            return nil
        }

        return path
    }

    static var undeadLegacyDirectory: URL? {
        guard let path = undeadLegacyPath else {
            return nil
        }

        return URL(
            fileURLWithPath: path,
            isDirectory: true
        )
    }
}