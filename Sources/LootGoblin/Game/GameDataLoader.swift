import Foundation

#if canImport(FoundationXML)
    import FoundationXML
#endif

import CLibXML2

private final class ItemCountingParserDelegate: NSObject, XMLParserDelegate {
    var itemCount = 0

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            itemCount += 1
        }
    }
}

enum GameDataLoaderError: LocalizedError {
    case invalidXML

    var description: String? {
        switch self {
        case .invalidXML:
            return "Unable to parse the XML file."
        }
    }
}

struct GameDataLoader {
    func countItems(at url: URL) throws -> Int {
        guard let parser = XMLParser(contentsOf: url) else {
            throw GameDataLoaderError.invalidXML
        }
        let delegate = ItemCountingParserDelegate()
        parser.delegate = delegate

        guard parser.parse() else {
            throw GameDataLoaderError.invalidXML
        }

        return delegate.itemCount
    }
}