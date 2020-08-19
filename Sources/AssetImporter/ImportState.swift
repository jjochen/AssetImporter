import Foundation

public enum ImportState: String {
    case replaced
    case skipped
    case new
}

public struct ImportStateCounter: CustomStringConvertible {
    var replaced: Int = 0
    var skipped: Int = 0
    var new: Int = 0

    var total: Int {
        return replaced + skipped + new
    }

    mutating func increment(forState state: ImportState) {
        switch state {
        case .replaced:
            replaced += 1
        case .skipped:
            skipped += 1
        case .new:
            new += 1
        }
    }

    func currentCount(forState state: ImportState) -> Int {
        switch state {
        case .replaced:
            return replaced
        case .skipped:
            return skipped
        case .new:
            return new
        }
    }

    public var description: String {
        var components: [String] = []
        components.append(description(forState: .replaced))
        components.append(description(forState: .skipped))
        components.append(description(forState: .new))
        return components.joined(separator: "\n")
    }

    func description(forState state: ImportState) -> String {
        return "\(state.rawValue.capitalized): \(currentCount(forState: state))"
    }
}
