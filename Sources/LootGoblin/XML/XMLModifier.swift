import Foundation

enum XMLModifierError: Error {
    case circularInclude(URL)
    case unsupportedOperation(String)
}

struct XMLModifier {
    func apply(
        _ modifications: XMLDocument,
        to document: XMLDocument,
        sourceURL: URL? = nil
    ) throws {
        var activeIncludes = Set<URL>()

        try apply(
            modifications,
            to: document,
            sourceURL: sourceURL,
            activeIncludes: &activeIncludes
        )
    }

    private func apply(
        _ modifications: XMLDocument,
        to document: XMLDocument,
        sourceURL: URL?,
        activeIncludes: inout Set<URL>
    ) throws {
        let normalizedURL = sourceURL?.standardizedFileURL

        if let normalizedURL {
            guard activeIncludes.insert(normalizedURL).inserted else {
                throw XMLModifierError.circularInclude(normalizedURL)
            }
        }

        defer {
            if let normalizedURL {
                activeIncludes.remove(normalizedURL)
            }
        }

        let operations = try modifications.nodes(matching: "/Subquake/*")

        for operation in operations {
            switch operation.name {
            case "include":
                guard let filename = operation.attributes["filename"],
                      let sourceURL else {
                    continue
                }

                let includedURL = sourceURL
                    .deletingLastPathComponent()
                    .appendingPathComponent(filename)

                let includedDocument = try XMLDocument(
                    contentsOf: includedURL
                )

                try apply(
                    includedDocument,
                    to: document,
                    sourceURL: includedURL,
                    activeIncludes: &activeIncludes
                )

            case "remove":
                guard let xpath = operation.attributes["xpath"] else {
                    continue
                }

                try document.removeNodes(matching: xpath)

            case "set":
                guard let xpath = operation.attributes["xpath"] else {
                    continue
                }

                if operation.children.isEmpty {
                    try document.setValue(
                        matching: xpath,
                        to: operation.content.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                    )
                } else {
                    try document.replaceChildren(
                        matching: xpath,
                        with: operation.children
                    )
                }

            case "append":
                guard let xpath = operation.attributes["xpath"] else {
                    continue
                }

                try document.appendChildren(
                    matching: xpath,
                    with: operation.children
                )

                try document.appendValue(
                    matching: xpath,
                    with: operation.content.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                )

            case "insertBefore":
                guard let xpath = operation.attributes["xpath"] else {
                    continue
                }

                try document.insertBefore(
                    matching: xpath,
                    with: operation.children
                )

            case "insertAfter":
                guard let xpath = operation.attributes["xpath"] else {
                    continue
                }

                try document.insertAfter(
                    matching: xpath,
                    with: operation.children
                )

            default:
                throw XMLModifierError.unsupportedOperation(
                    operation.name
                )
            }
        }
    }
}