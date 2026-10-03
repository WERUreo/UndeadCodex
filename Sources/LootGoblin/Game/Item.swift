import Foundation

struct Item: Equatable {
    let name: String
    let properties: [String: String]

    var stackSize: Int? {
        properties["Stacknumber"].flatMap(Int.init)
    }

    var material: String? {
        properties["Material"]
    }

    var economicValue: Int? {
        properties["EconomicValue"].flatMap(Int.init)
    }
}