import Foundation
import LaunchServices

enum XcodeArch {
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
    }
}

private extension XcodeArch {
    static func getCurrentXcodePath() async throws -> String {
        let process = Process()
        process.launchPath = "/usr/bin/xcode-select"
        process.arguments = ["-p"]
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let developerDir = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines),
              developerDir.hasSuffix("/Contents/Developer") else { throw XcodeArchError.unknownXcodePath }
        return developerDir.replacingOccurrences(of: "/Contents/Developer", with: "")
    }

    static func getLaunchServicesPlist() async throws -> [(path: String, arch: String)] {
        let fm = FileManager.default
        let plistUrl = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Preferences/com.apple.LaunchServices/com.apple.LaunchServices.plist")
        guard fm.fileExists(atPath: plistUrl.path) else { throw XcodeArchError.launchServicesPlistNotFound }
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
            guard let path = getResolvedAliasPathInData(data) else { continue }
            result.append((path, arch))
        }
        return result
    }
}

enum Architecture: String, CaseIterable {
    case x86_64
    case arm64
}

enum XcodeArchError: Error {
    case unknownXcodePath
    case launchServicesPlistNotFound
    case invalidPlist
}
