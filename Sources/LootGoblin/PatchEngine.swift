import Foundation
import CLibXML2

struct PatchEngine {
    func apply(_ patch: SetPatch, to document: XMLDocument) throws {
        switch patch.payload {
        case .value(let value):
            try document.setValue(
                matching: patch.xpath,
                to: value
            )
        case .elements(let elements):
            try document.replaceChildren(
                matching: patch.xpath, 
                with: elements
            )
        }
    }

    func apply(_ patches: [SetPatch], to document: XMLDocument) throws {
        for patch in patches {
            try apply(patch, to: document)
        }
    }
}