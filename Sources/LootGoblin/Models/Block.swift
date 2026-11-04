struct Block: Equatable {
    let name: String
    let parentName: String?
    let drops: [Drop]
    let dropExtendsOff: Bool

    init(
        name: String, 
        parentName: String? = nil,
        drops: [Drop] = [],
        dropExtendsOff: Bool = false
    ) {
        self.name = name
        self.parentName = parentName
        self.drops = drops
        self.dropExtendsOff = dropExtendsOff
    }
}

extension Block {
    struct Drop: Equatable {
        let event: Event
        let itemName: String?
        let count: String

        enum Event: String {
            case harvest = "Harvest"
            case destroy = "Destroy"
            case fall = "Fall"
        }
    }
}