import Foundation

struct SetPatch {
    let xpath: String
    let payload: Payload

    enum Payload: Equatable {
        case value(String)
        case elements([XMLNode])
    }
}