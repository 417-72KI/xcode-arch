import Foundation
import LaunchServices

enum XcodeArch {
    static var shellRunner: ShellRunner.Type = DefaultShellRunner.self

    static func printCurrent() async throws {
        let xcodePath = try await getCurrentXcodePath()
        print(xcodePath)
        let archs = try await getLaunchServicesPlist()
        let arch = (archs.first(where: { $0.path == xcodePath })?.arch)
            .flatMap(Architecture.init(rawValue:)) ?? .arm64

        print("\u{001B}[0;32m`\(xcodePath)` is running with \(arch)\u{001B}[0;m")
    }

    static func switchArch(_ arch: Architecture) async throws {
        let xcodePath = try await getCurrentXcodePath()
        _LSSetArchitecturePreferenceForApplicationURL(URL(fileURLWithPath: xcodePath), arch.rawValue)

        print("\u{001B}[0;32mSet \(arch) for \(xcodePath)\u{001B}[0;m")

        try await killXcode()
    }
}

private extension XcodeArch {
    static func getCurrentXcodePath() async throws -> String {
        guard let developerDir = try shellRunner.run("/usr/bin/xcode-select", with: ["-p"]).stringOutput,
              developerDir.hasSuffix("/Contents/Developer") else { throw XcodeArchError.unknownXcodePath }
        return developerDir.replacingOccurrences(of: "/Contents/Developer", with: "")
    }

    static func killXcode() async throws {
        try shellRunner.run("/usr/bin/killall", with: ["Xcode"])
    }

    static func getLaunchServicesPlist() async throws -> [(path: String, arch: String)] {
        let fm = FileManager.default
        let plistUrl = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Preferences/com.apple.LaunchServices/com.apple.LaunchServices.plist")
        guard fm.fileExists(atPath: plistUrl.path) else { throw XcodeArchError.launchServicesPlistNotFound(plistUrl) }
        guard let plist = try PropertyListSerialization.propertyList(from: Data(contentsOf: plistUrl), format: nil) as? [String: [String: [Any]]],
              let archs = plist["Architectures for arm64"] else { throw XcodeArchError.invalidPlist }
        guard let xcodeArchs = archs["com.apple.dt.Xcode"] else {
            return []
        }
        guard xcodeArchs.count % 2 == 0 else { throw XcodeArchError.invalidPlist }
        var result: [(String, String)] = []
        for i in (0 ..< xcodeArchs.count / 2) {
            guard let data = xcodeArchs[i * 2] as? Data,
                  let arch = xcodeArchs[i * 2 + 1] as? String else { continue }
            let path = getResolvedAliasPath(in: data)
            result.append((path, arch))
        }
        return result
    }

    static func getResolvedAliasPath(in data: Data) -> String {
        let url = CFURLCreateByResolvingBookmarkData(nil, data as CFData, [], nil, nil, nil, nil)
            .takeRetainedValue() as URL
        return url.path
    }
}

enum Architecture: String, CaseIterable {
    case x86_64
    case arm64
}

enum XcodeArchError: Error {
    case runningInX86_64
    case invalidArchitecture(String)
    case unknownXcodePath
    case launchServicesPlistNotFound(URL)
    case invalidPlist
}

extension XcodeArchError: CustomStringConvertible {
    var description: String {
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
