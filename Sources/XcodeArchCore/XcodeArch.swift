import Foundation
import ObjCBridge

public enum XcodeArch {
    static var shellRunner: ShellRunner.Type = DefaultShellRunner.self
}

public extension XcodeArch {
    static func printCurrent() async throws {
        let xcodePath = try await getCurrentXcodePath()
        let archs = try await getLaunchServicesPlist()
        let arch = (archs.first(where: { $0.path == xcodePath })?.arch)
            .flatMap(Architecture.init(rawValue:)) ?? .arm64

        print("\u{001B}[0;32m`\(xcodePath)` is running with \(arch)\u{001B}[0;m")
    }

    static func switchArch(_ arch: Architecture) async throws {
        let xcodePath = try await getCurrentXcodePath()
        LSSetArchitecturePreferenceForApplicationURL(URL(fileURLWithPath: xcodePath), arch.rawValue)
        print("\u{001B}[0;32mSet \(arch) for \(xcodePath)\u{001B}[0;m")

        try await killXcode()
    }
}

extension XcodeArch {
    static func getCurrentXcodePath() async throws -> String {
        guard let developerDir = try shellRunner.run("/usr/bin/xcode-select", with: ["-p"]).stringOutput,
              developerDir.hasSuffix("/Contents/Developer") else { throw XcodeArchError.unknownXcodePath }
        return developerDir.replacingOccurrences(of: "/Contents/Developer", with: "")
    }

    static func killXcode() async throws {
        try shellRunner.run("/usr/bin/killall", with: ["Xcode"])
    }

    static func getLaunchServicesPlist(_ fileManager: FileManager = .default) async throws -> [(path: String, arch: String)] {
        let plistUrl = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Preferences/com.apple.LaunchServices/com.apple.LaunchServices.plist")
        guard fileManager.fileExists(atPath: plistUrl.path) else { throw XcodeArchError.launchServicesPlistNotFound(plistUrl) }
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
            guard let path = getResolvedAliasPath(in: data) else {
                // Removed Xcode
                continue
            }
            result.append((path, arch))
        }
        return result
    }

    static func getResolvedAliasPath(in data: Data) -> String? {
        guard let cfurl = CFURLCreateByResolvingBookmarkData(nil, data as CFData, [], nil, nil, nil, nil) else { return nil }
        let url = cfurl.takeRetainedValue() as URL
        return url.path
    }
}
