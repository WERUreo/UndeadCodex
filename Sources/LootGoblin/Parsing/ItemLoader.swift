import Foundation

struct ItemLoader {
    func loadItems(from url: URL) throws -> [Item] {
        let document = try XMLDocument(contentsOf: url)
        let nodes = try document.nodes(matching: "/items/item")

        var items: [Item] = []

        for node in nodes {
            guard let name = node.attributes["name"] else {
                continue
            }

            var properties: [String: String] = [:]

            for child in node.children {
                guard child.name == "property",
                    let attributeName = child.attributes["name"],
                    let attributeValue = child.attributes["value"] else {
                    continue
                }
        
                properties[attributeName] = attributeValue
            }

            items.append(Item(name: name, properties: properties))
        }

        return items
    }
}