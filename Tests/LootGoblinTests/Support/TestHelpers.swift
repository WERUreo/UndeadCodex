import Foundation
import Testing

func fixtureURL(named name: String) throws -> URL {
    try #require(
        Bundle.module.url(
            forResource: name,
            withExtension: "xml",
            subdirectory: "Fixtures"
        )
    )
}