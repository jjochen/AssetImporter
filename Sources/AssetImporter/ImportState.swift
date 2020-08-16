import Foundation

public enum ImportState: String {
    case imported
    case skipped
    case new
}

public struct ImportStateCounter: CustomStringConvertible {
    var imported = 0
    var skipped = 0
    var new = 0

    mutating func increment(forState state: ImportState) {
        switch state {
        case .imported:
            imported += 1
        case .skipped:
            skipped += 1
        case .new:
            new += 1
        }
    }

    func currentCount(forState state: ImportState) -> Int {
        switch state {
        case .imported:
            return imported
        case .skipped:
            return skipped
        case .new:
            return new
        }
    }

    public var description: String {
        var components: [String] = []
        components.append(description(forState: .imported))
        components.append(description(forState: .skipped))
        components.append(description(forState: .new))
        return components.joined(separator: "\n")
    }

    func description(forState state: ImportState) -> String {
        return "\(state.rawValue.capitalized): \(currentCount(forState: state))"
    }
}
