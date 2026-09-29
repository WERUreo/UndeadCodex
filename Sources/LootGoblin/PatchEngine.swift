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
        case .elements:
            break
        }
    }
}