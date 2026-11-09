import Foundation

struct LocalizationLoader {
    func load(from url: URL) throws -> [LocalizationEntry] {
        let contents = try String(contentsOf: url, encoding: .utf8)
        let lines = contents.split(
            whereSeparator: \.isNewline
        )

        guard let headerLine = lines.first else {
            return []
        }

        let parser = CSVParser()
        let headers = parser.parse(String(headerLine))

        guard let keyIndex = headers.firstIndex(of: "Key"),
            let fileIndex = headers.firstIndex(of: "File"),
            let typeIndex = headers.firstIndex(of: "Type"),
            let englishIndex = headers.firstIndex(of: "english") else {
            return []
        }

        var entries: [LocalizationEntry] = []

        for line in lines.dropFirst() {
            let fields = parser.parse(String(line))

            guard fields.indices.contains(keyIndex),
                fields.indices.contains(fileIndex),
                fields.indices.contains(typeIndex),
                fields.indices.contains(englishIndex) else {
                continue
            }

            entries.append(LocalizationEntry(
                key: fields[keyIndex],
                file: fields[fileIndex],
                type: fields[typeIndex],
                english: fields[englishIndex]
            ))
        }

        return entries
    }
}