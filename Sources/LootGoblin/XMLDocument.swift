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

struct XMLNode {
    let attributes: [String: String]
    let content: String
}

final class XMLDocument {
    private let doc: xmlDocPtr

    init(contentsOf url: URL) throws {
        guard let doc = xmlReadFile(url.path, nil, 0) else {
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
                guard let node = nodes[index] else {
                    continue
                }

                var attributes: [String: String] = [:]
                var property = node.pointee.properties

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

                // Extract content and attributes here
                guard let contentPointer = xmlNodeGetContent(node) else {
                    continue
                }

                defer {
                    lg_xmlFree(contentPointer)
                }

                let content = String(
                    cString: UnsafeRawPointer(contentPointer)
                        .assumingMemoryBound(to: CChar.self)
                )

                result.append(
                    XMLNode(
                        attributes: attributes,
                        content: content
                    )
                )
            }

            return result
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
}