import Foundation

enum BlockLoader {
    // Load vanilla XML directly
    static func load(from data: Data) throws -> [Block] {
        try loadWithDiagnostics(from: data).blocks
    }

    // Load an already-patched XML document
    static func load(from document: XMLDocument) throws -> [Block] {
        try loadWithDiagnostics(from: document).blocks
    }

    static func loadWithDiagnostics(
        from data: Data
    ) throws -> BlockLoadResult {
        let document = try XMLDocument(data: data)
        return try loadWithDiagnostics(from: document)
    }

    static func loadWithDiagnostics(
        from document: XMLDocument
    ) throws -> BlockLoadResult {
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

            let dropExtendsOff = node.children.contains {
                $0.name == "dropextendsoff"
            }

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
                drops: drops,
                dropExtendsOff: dropExtendsOff
            )
        }

        let blocksByName = Dictionary(
            uniqueKeysWithValues: blocks.map { ($0.name, $0) }
        )

        var diagnostics: [Diagnostic] = []
        var reportedCycles: Set<Set<String>> = []

        func resolveDrops(
            for block: Block,
            visited: [String] = []
        ) -> [Block.Drop] {
            if let cycleStart = visited.firstIndex(of: block.name) {
                let cycle = Set(visited[cycleStart...])

                if reportedCycles.insert(cycle).inserted {
                    diagnostics.append(
                        Diagnostic(
                            severity: .warning,
                            message: "Circular inheritance detected for blocks: \(cycle.sorted().joined(separator: ", "))"
                        )
                    )
                }

                return []
            }

            guard !block.dropExtendsOff,
                  let parentName = block.parentName,
                  let parent = blocksByName[parentName] else {
                    return block.drops
            }

            let inheritedDrops = resolveDrops(
                for: parent,
                visited: visited + [block.name]
            )

            return inheritedDrops + block.drops
        }

        let resolvedBlocks = blocks.map { block in
            Block(
                name: block.name,
                parentName: block.parentName,
                drops: resolveDrops(for: block),
                dropExtendsOff: block.dropExtendsOff
            )
        }

        return BlockLoadResult(
            blocks: resolvedBlocks,
            diagnostics: diagnostics
        )
    }
}