import Foundation

struct LocalizationCatalog {
    let entries: [LocalizationEntry]

    init(
        entries: [LocalizationEntry],
        patches: [LocalizationEntry] = []
    ) {
        var merged: [LocalizationEntry] = []
        var seenKeys: Set<String> = []
        var indices: [String: Int] = [:]

        for entry in entries {
            if seenKeys.insert(entry.key).inserted {
                let normalizedKey = entry.key.lowercased()

                if indices[normalizedKey] == nil {
                    indices[normalizedKey] = merged.count
                }

                merged.append(entry)
            }
        }

        for patch in patches {
            let normalizedKey = patch.key.lowercased()

            if let index = indices[normalizedKey] {
                let existing = merged[index]

                merged[index] = LocalizationEntry(
                    key: existing.key,
                    file: patch.file.isEmpty ? existing.file : patch.file,
                    type: patch.type.isEmpty ? existing.type : patch.type,
                    english: patch.english.isEmpty ? existing.english : patch.english
                )
            } else {
                indices[normalizedKey] = merged.count
                merged.append(patch)
            }
        }

        self.entries = merged
    }

    func name(for key: String) -> String? {
        guard let entry = entries.first(where: {
            $0.key == key
        }), !entry.english.isEmpty else {
            return nil
        }

        return entry.english
    }

    func key(for localizedName: String) -> String? {
        guard !localizedName.isEmpty else {
            return nil
        }

        return entries.first {
            $0.english.caseInsensitiveCompare(localizedName) == .orderedSame
        }?.key
    }
}