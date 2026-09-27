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

struct PatchLoader {
    func loadSetPatches(from url: URL) throws -> [SetPatch] {
        let document = try XMLDocument(contentsOf: url)
        let setNodes = try document.nodes(matching: "//set")
        var setPatches: [SetPatch] = []

        for node in setNodes {
            guard
                let xpath = node.attributes["xpath"],
                !xpath.isEmpty
            else {
                throw PatchLoaderError.missingXPath
            }
            
            let payload: SetPatch.Payload

            if node.hasElementChildren {
                payload = .elements
            } else {
                payload = .value(node.content)
            }

            let patch = SetPatch(
                xpath: xpath,
                payload: payload
            )

            setPatches.append(patch)
        }
        
        return setPatches
    }
}