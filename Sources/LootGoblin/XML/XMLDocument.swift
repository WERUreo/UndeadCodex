import Foundation
import CLibXML2

enum XMLDocumentError: LocalizedError {
    case unableToReadFile
    case unableToCreateXPathContext
    case unableToEvaluateXPath

    var errorDescription: String? {
        switch self {
        case .unableToReadFile:
            return "Unable to parse the XML file."
        case .unableToCreateXPathContext:
            return "Unable to create an XPath context for the XML document."
        case .unableToEvaluateXPath:
            return "Unable to evaluate the XPath expression."
        }
    }
}

struct XMLNode: Equatable {
    let name: String
    let attributes: [String: String]
    let content: String
    let children: [XMLNode]
}

final class XMLDocument {
    private let doc: xmlDocPtr

    init(contentsOf url: URL) throws {
        guard let doc = xmlReadFile(url.path, nil, 0) else {
            throw XMLDocumentError.unableToReadFile
        }

        self.doc = doc
    }

    init(data: Data) throws {
        let doc = data.withUnsafeBytes { buffer in
            xmlReadMemory(
                buffer.baseAddress?.assumingMemoryBound(to: CChar.self),
                Int32(buffer.count),
                nil,
                nil,
                0
            )
        }

        guard let doc else {
            throw XMLDocumentError.unableToReadFile
        }

        self.doc = doc
    }

    deinit {
        xmlFreeDoc(doc)
    }

    func countNodes(matching xpath: String) throws -> Int {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return 0
            }

            return Int(nodeSet.pointee.nodeNr)
        }    
    }

    func setValue(matching xpath: String, to value: String) throws {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return
            }

            for index in 0..<count {
                guard let node = nodes[index] else {
                    continue
                }

                value.withCString { valueCString in
                    xmlNodeSetContent(
                        node,
                        UnsafeRawPointer(valueCString)
                            .assumingMemoryBound(to: xmlChar.self)
                    )}
            }
        }
    }

    func nodes(matching xpath: String) throws -> [XMLNode] {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return []
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return []
            }

            var result: [XMLNode] = []

            for index in 0..<count {
                guard let node = nodes[index],
                    let xmlNode = makeNode(from: node) else {
                    continue
                }

                result.append(xmlNode)
            }

            return result
        }
    }

    func replaceChildren(matching xpath: String, with children: [XMLNode]) throws {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return 
            }

            for index in 0..<count {
                guard let node = nodes[index] else {
                    continue
                }

                removeChildren(from: node)

                for child in children {
                    guard let newChild = makeLibXMLNode(from: child) else {
                        continue
                    }

                    _ = xmlAddChild(node, newChild)
                }
            }
        }
    }

    func appendChildren(
        matching xpath: String,
        with children: [XMLNode]
    ) throws {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return
            }

            for index in 0..<count {
                guard let node = nodes[index] else {
                    continue
                }

                for child in children {
                    guard let newChild = makeLibXMLNode(from: child) else {
                        continue
                    }

                    _ = xmlAddChild(node, newChild)
                }
            }
        }
    }

    func appendValue(matching xpath: String, with value: String) throws {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return
            }

            for index in 0..<count {
                guard let node = nodes[index],
                    node.pointee.type == XML_ATTRIBUTE_NODE else {
                    continue
                }

                guard let valuePointer = xmlNodeGetContent(node) else {
                    continue
                }

                let existing = String(
                    cString: UnsafeRawPointer(valuePointer)
                        .assumingMemoryBound(to: CChar.self)
                )

                lg_xmlFree(valuePointer)

                xmlNodeSetContent(node, existing + value)
            }
        }
    }

    func insertBefore(
        matching xpath: String,
        with children: [XMLNode]
    ) throws {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return
            }

            for index in 0..<count {
                guard let node = nodes[index] else {
                    continue
                }

                // insertBefore only supports element targets.
                guard node.pointee.type == XML_ELEMENT_NODE else {
                    continue
                }

                for child in children {
                    guard let newChild = makeLibXMLNode(from: child) else {
                        continue
                    }

                    _ = xmlAddPrevSibling(node, newChild)
                }
            }
        }
    }

    func insertAfter(
        matching xpath: String,
        with children: [XMLNode]
    ) throws {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return
            }

            for index in 0..<count {
                guard let node = nodes[index] else {
                    continue
                }

                guard node.pointee.type == XML_ELEMENT_NODE else {
                    continue
                }

                for child in children.reversed() {
                    guard let newChild = makeLibXMLNode(from: child) else {
                        continue
                    }

                    _ = xmlAddNextSibling(node, newChild)
                }
            }
        }
    }

    func removeNodes(matching xpath: String) throws {
        try withNodes(matching: xpath) { nodeSet in
            guard let nodeSet else {
                return
            }

            let count = Int(nodeSet.pointee.nodeNr)

            guard count > 0, let nodes = nodeSet.pointee.nodeTab else {
                return
            }

            // Collect all matching nodes.
            var selectedNodes: [xmlNodePtr] = []

            for index in 0..<count {
                if let node = nodes[index] {
                    selectedNodes.append(node)
                }
            }

            // Keep track of selected node addresses.
            let selectedAddresses = Set(
                selectedNodes.map { UInt(bitPattern: $0) }
            )

            // Exclude nodes whose ancestors are also selected.
            var nodesToRemove: [xmlNodePtr] = []

            for node in selectedNodes {
                var ancestor = node.pointee.parent
                var hasSelectedAncestor = false

                while let current = ancestor {
                    if selectedAddresses.contains(UInt(bitPattern: current)) {
                        hasSelectedAncestor = true
                        break
                    }

                    ancestor = current.pointee.parent
                }

                if !hasSelectedAncestor {
                    nodesToRemove.append(node)
                }
            }

            // All pointer inspection is finished; now it's safe to free.
            for node in nodesToRemove {
                xmlUnlinkNode(node)
                xmlFreeNode(node)
            }
        }
    }
}

private extension XMLDocument {
    func withNodes<T>(
        matching xpath: String,
        _ body: (xmlNodeSetPtr?) throws -> T
    ) throws -> T {
        guard let context = xmlXPathNewContext(doc) else {
            throw XMLDocumentError.unableToCreateXPathContext
        }

        defer {
            xmlXPathFreeContext(context)
        }

        let result = xpath.withCString { xpathCString in
            xmlXPathEvalExpression(
                UnsafeRawPointer(xpathCString)
                    .assumingMemoryBound(to: xmlChar.self),
                context
            )
        }

        guard let result else {
            throw XMLDocumentError.unableToEvaluateXPath
        }

        defer {
            xmlXPathFreeObject(result)
        }

        return try body(result.pointee.nodesetval)
    }

    func removeChildren(from node: xmlNodePtr) {
        var child = node.pointee.children

        while let currentChild = child {
            let nextChild = currentChild.pointee.next

            xmlUnlinkNode(currentChild)
            xmlFreeNode(currentChild)

            child = nextChild
        }
    }

    func makeNode(from node: xmlNodePtr) -> XMLNode? {
        guard let namePointer = node.pointee.name else {
            return nil
        }

        let name = String(
            cString: UnsafeRawPointer(namePointer)
                .assumingMemoryBound(to: CChar.self)
        )

        var attributes: [String: String] = [:]
        var property = node.pointee.properties
        var child = node.pointee.children
        var children: [XMLNode] = []

        while let currentProperty = property {
            if let namePointer = currentProperty.pointee.name {
                let name = String(
                    cString: UnsafeRawPointer(namePointer)
                        .assumingMemoryBound(to: CChar.self)
                )

                if let valuePointer = xmlNodeListGetString(doc, currentProperty.pointee.children, 1) {
                    let value = String(
                        decodingCString: valuePointer, 
                        as: UTF8.self
                    )

                    lg_xmlFree(valuePointer)

                    attributes[name] = value
                }

            }

            property = currentProperty.pointee.next
        }

        guard let contentPointer = xmlNodeGetContent(node) else {
            return nil
        }

        defer {
            lg_xmlFree(contentPointer)
        }

        let content = String(
            cString: UnsafeRawPointer(contentPointer)
                .assumingMemoryBound(to: CChar.self)
        )

        while let currentChild = child {
            if currentChild.pointee.type == XML_ELEMENT_NODE {
                if let childNode = makeNode(from: currentChild) {
                    children.append(childNode)
                }
            }

            child = currentChild.pointee.next
        }

        return XMLNode(
            name: name, 
            attributes: attributes, 
            content: content, 
            children: children
        )
    }

    func makeLibXMLNode(from node: XMLNode) -> xmlNodePtr? {
        guard let newNode = node.name.withCString({ nameCString in
            xmlNewNode(
                nil, 
                UnsafeRawPointer(nameCString)
                    .assumingMemoryBound(to: xmlChar.self)    
            )
        }) else {
            return nil
        }

        for (name, value) in node.attributes {
            _ = name.withCString { nameCString in
                value.withCString { valueCString in
                    xmlNewProp(
                        newNode,
                        UnsafeRawPointer(nameCString)
                            .assumingMemoryBound(to: xmlChar.self),
                        UnsafeRawPointer(valueCString)
                            .assumingMemoryBound(to: xmlChar.self)
                    )
                }
            }
        }

        for child in node.children {
            guard let newChild = makeLibXMLNode(from: child) else {
                continue
            }

            _ = xmlAddChild(
                newNode,
                newChild
            )
        }

        return newNode
    }
}