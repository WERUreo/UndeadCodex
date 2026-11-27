enum BlockQuery {
    static func blocks(
        dropping itemName: String,
        from blocks: [Block]
    ) -> [Block] {
        blocks.filter { block in
            block.drops.contains { drop in
                drop.event == .harvest &&
                drop.itemName == itemName
            }
        }
    }

    static func matches(
        dropping itemName: String,
        from blocks: [Block]
    ) -> [BlockDropMatch] {
        blocks.compactMap { block in
            let matchingDrops = block.drops.filter { drop in
                drop.event == .harvest &&
                drop.itemName == itemName
            }

            guard !matchingDrops.isEmpty else {
                return nil
            }

            return BlockDropMatch(
                block: block,
                drops: matchingDrops
            )
        }
    }
}