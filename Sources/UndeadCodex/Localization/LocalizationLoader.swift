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
            .map { $0.lowercased() }

        guard let keyIndex = headers.firstIndex(of: "key"),
            let englishIndex = headers.firstIndex(of: "english") else {
            return []
        }

        let fileIndex = headers.firstIndex(of: "file")
        let typeIndex = headers.firstIndex(of: "type")

        var entries: [LocalizationEntry] = []

        for line in lines.dropFirst() {
            let fields = parser.parse(String(line))

            guard fields.indices.contains(keyIndex),
                fields.indices.contains(englishIndex) else {
                continue
            }

            let file = fileIndex.flatMap {
                fields.indices.contains($0) ? fields[$0] : nil
            } ?? ""

            let type = typeIndex.flatMap {
                fields.indices.contains($0) ? fields[$0] : nil
            } ?? ""

            entries.append(LocalizationEntry(
                key: fields[keyIndex],
                file: file,
                type: type,
                english: fields[englishIndex]
            ))
        }

        return entries
    }
}