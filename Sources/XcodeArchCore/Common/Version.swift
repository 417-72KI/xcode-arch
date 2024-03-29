import Foundation

public struct Version {
    /// The major version.
    ///
    /// Increments to this component represent incompatible API changes.
    public let major: Int

    /// The minor version.
    ///
    /// Increments to this component represent backwards-compatible
    /// enhancements.
    public let minor: Int

    /// The patch version.
    ///
    /// Increments to this component represent backwards-compatible bug fixes.
    public let patch: Int

    /// The pre-release identifier
    ///
    /// Indicates that the version is unstable
    public let preRelease: String?

    /// The build metadata
    ///
    /// Build metadata is ignored when comparing versions
    public let buildMetadata: String?

    public init(_ major: Int, _ minor: Int, _ patch: Int, preRelease: String? = nil, buildMetadata: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.preRelease = preRelease
        self.buildMetadata = buildMetadata
    }
}

// MARK: - Convenience initializers
public extension Version {
    init(_ string: String) {
        self.init(stringLiteral: string)
    }

    #if swift(>=5.7)
    init(_ string: any StringProtocol) {
        self.init(String(string))
    }
    #else
    init(_ string: Substring) {
        self.init(String(string))
    }
    #endif
}

// MARK: - Public properties
extension Version {
    /// A list of the version components, in order from most significant to
    /// least significant.
    public var components: [Int] { [major, minor, patch] }

    /// Whether this is a prerelease version
    public var isPreRelease: Bool { preRelease != nil }
}

// MARK: - Hashable
extension Version: Hashable {
    public func hash(into hasher: inout Hasher) {
        components.forEach { hasher.combine($0) }
    }
}

// MARK: - Comparable
extension Version: Comparable {
    public static func < (_ lhs: Version, _ rhs: Version) -> Bool {
        if lhs.components == rhs.components {
            guard let lpr = lhs.preRelease else { return false }
            guard let rpr = rhs.preRelease else { return true }
            return lpr < rpr
        }
        return lhs.components.lexicographicallyPrecedes(rhs.components)
    }
}

// MARK: - CustomStringConvertible
extension Version: CustomStringConvertible {
    public var description: String {
        var description = components.map(String.init)
            .joined(separator: ".")
        if let preRelease = preRelease {
            description += "-\(preRelease)"
        }
        if let buildMetadata = buildMetadata {
            description += "+\(buildMetadata)"
        }
        return description
    }
}

// MARK: - ExpressibleByStringLiteral
extension Version: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        // swiftlint:disable:next line_length
        let pattern = #"^v?(?<major>0|[1-9]\d*)(\.(?<minor>0|[1-9]\d*))?(\.(?<patch>0|[1-9]\d*))?(?<pre>-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?(?<metadata>\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            fatalError("Invalid pattern: \(pattern)")
        }
        guard let result = regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) else {
            assertionFailure("Invalid value: \(value)")
            self.init(1, 0, 0)
            return
        }
        let ranges = (
            major: Range(result.range(withName: "major"), in: value),
            minor: Range(result.range(withName: "minor"), in: value),
            patch: Range(result.range(withName: "patch"), in: value),
            preRelease: Range(result.range(withName: "pre"), in: value),
            buildMetadata: Range(result.range(withName: "metadata"), in: value)
        )
        guard let major = ranges.major
            .flatMap({ Int(value[$0]) }) else { preconditionFailure() }
        let minor = ranges.minor
            .flatMap { Int(value[$0]) } ?? 0
        let patch = ranges.patch
            .flatMap { Int(value[$0]) } ?? 0
        let preRelease = ranges.preRelease
            .flatMap { String(value[$0].dropFirst()) }
        let buildMetadata = ranges.buildMetadata
            .flatMap { String(value[$0].dropFirst()) }
        self.init(major, minor, patch, preRelease: preRelease, buildMetadata: buildMetadata)
    }
}
