import Foundation
import Testing

func fixtureURL(
    named name: String, 
    extension fileExtension: String = "xml"
) throws -> URL {
    let url = Bundle.module.url(
        forResource: name,
        withExtension: fileExtension,
        subdirectory: "Fixtures"
    )

    return try #require(url)
}