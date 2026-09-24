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

        guard let nodeset = result.pointee.nodesetval else {
            return 0
        }

        return Int(nodeset.pointee.nodeNr)
    }
}