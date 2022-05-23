import Foundation

public enum XcodeArchError: Error {
    case runningInX86_64
    case invalidArchitecture(String)
    case unknownXcodePath
    case launchServicesPlistNotFound(URL)
    case invalidPlist
}

// MARK: - CustomStringConvertible
extension XcodeArchError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .runningInX86_64:
            return "Running in `x86_64` arch. This tool supports only `arm64`"
        case let .invalidArchitecture(actual):
            return "Invalid architecture: \(actual)"
        case .unknownXcodePath:
            return "Xcode is not installed"
        case let .launchServicesPlistNotFound(expected):
            return "\(expected) not found."
        case .invalidPlist:
            return "Invalid plist"
        }
    }
}
