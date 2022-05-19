import Foundation
import LaunchServices

enum XcodeArch {
    static func printCurrent() async throws {
        let xcodePath = try await getCurrentXcodePath()
        print(xcodePath)
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
}

enum Architecture: String, CaseIterable {
    case x86_64
    case arm64
}

enum XcodeArchError: Error {
    case unknownXcodePath
}
