struct Diagnostic: Equatable {
    let severity: Severity
    let message: String

    enum Severity {
        case warning
        case error
    }
}