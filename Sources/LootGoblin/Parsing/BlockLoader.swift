import Foundation

enum BlockLoader {
    static func load(from data: Data) throws -> [Block] {
        let document = try XMLDocument(data: data)
        let nodes = try document.nodes(matching: "/blocks/block")

        let blocks = nodes.compactMap { node -> Block? in
            guard let name = node.attributes["name"] else {
                return nil
            }

            let parentName = node.children
                .first {
                    $0.name == "property" &&
                    $0.attributes["name"] == "Extends"
                }?
                .attributes["value"]

            let drops = node.children.compactMap { child -> Block.Drop? in
                guard child.name == "drop",
                      let eventName = child.attributes["event"],
                      let event = Block.Drop.Event(rawValue: eventName),
                      let count = child.attributes["count"] else {
                        return nil
                }

                return Block.Drop(
                    event: event,
                    itemName: child.attributes["name"],
                    count: count
                )
            }

            return Block(
                name: name, 
                parentName: parentName,
                drops: drops
            )
        }

        let blocksByName = Dictionary(
            uniqueKeysWithValues: blocks.map { ($0.name, $0) }
        )

        func resolveDrops(
            for block: Block,
            visited: Set<String> = []
        ) -> [Block.Drop] {
            if visited.contains(block.name) {
                return []
            }

            guard let parentName = block.parentName,
                  let parent = blocksByName[parentName] else {
                    return block.drops
            }

            let inheritedDrops = resolveDrops(
                for: parent,
                visited: visited.union([block.name])
            )

            return inheritedDrops + block.drops
        }

        return blocks.map { block in
            Block(
                name: block.name,
                parentName: block.parentName,
                drops: resolveDrops(for: block)
            )
        }
    }
}