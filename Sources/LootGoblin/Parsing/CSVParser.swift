struct CSVParser {
    func parse(_ row: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        var index = row.startIndex
        
        while index < row.endIndex {
            let character = row[index]

            if character == "\"" {
                let nextIndex = row.index(after: index)

                if insideQuotes,
                    nextIndex < row.endIndex,
                    row[nextIndex] == "\"" {
                        currentField.append("\"")
                        index = nextIndex
                } else {
                    insideQuotes.toggle()
                }
            } else if character == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(character)
            }

            index = row.index(after: index)
        }

        fields.append(currentField)
        return fields
    }
}