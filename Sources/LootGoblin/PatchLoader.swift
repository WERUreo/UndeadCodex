import Foundation
import CLibXML2

enum PatchLoaderError: LocalizedError, Equatable {
    case missingXPath

    var errorDescription: String? {
        switch self {
        case .missingXPath:
            return "Error: A set patch is missing its xpath attribute"
        }
    }
}

struct SetPatch {
    let xpath: String
    let value: String
}

struct PatchLoader {
    func loadSetNodes(from url: URL) throws -> [XMLNode] {
        let document = try XMLDocument(contentsOf: url)
        let setNodes = try document.nodes(matching: "//set")
        for node in setNodes {
            guard
                let xpath = node.attributes["xpath"],
                !xpath.isEmpty
            else {
                throw PatchLoaderError.missingXPath
            }
        }

        return setNodes
    }
}