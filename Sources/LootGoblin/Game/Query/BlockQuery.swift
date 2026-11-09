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
}