import ArgumentParser
import XcodeArchCore

@main
struct XcodeArchMain: AsyncParsableCommand {
    @Flag(name: .shortAndLong, help: "print current architecture of Xcode")
    var printCurrentArch = false

    @Option(name: [.customLong("switch"), .customShort("s")],
            parsing: .next,
            help: ArgumentHelp("set the architecture for Xcode (\(Architecture.allValueStrings.joined(separator: "|")))", valueName: "architecture"))
    var newArch: Architecture?

    @Flag(name: .shortAndLong, help: "set `\(Architecture.x86_64)` for Xcode")
    var checkRosetta = false

    @Flag(name: .shortAndLong, help: "set `\(Architecture.arm64)` for Xcode")
    var uncheckRosetta = false
}

extension XcodeArchMain {
    static var configuration: CommandConfiguration {
        .init(commandName: "xcode-arch",
              abstract: "A utility to switch running architecture of Xcode on M1 mac.",
              usage: "xcode-arch [options]",
              discussion: """
                To check/uncheck 'Open Using Rosetta' is bothering.
                This tool makes switching `checked/unchecked` easily.
                """,
              version: ApplicationInfo.version.description)
    }
}

extension XcodeArchMain {
    func run() async throws {
        try validateMachine()

        if printCurrentArch {
            try await XcodeArch.printCurrent()
            return
        }

        if let newArch = newArch {
            try await XcodeArch.switchArch(newArch)
            return
        }

        if checkRosetta {
            try await XcodeArch.switchArch(.x86_64)
            return
        }

        if uncheckRosetta {
            try await XcodeArch.switchArch(.arm64)
            return
        }

        throw CleanExit.helpRequest(self)
    }
}

private extension XcodeArchMain {
    func validateMachine() throws {
        let machineArch = try DefaultShellRunner.run("/usr/bin/uname", with: ["-m"]).stringOutput
        guard let machineArch = machineArch.flatMap(Architecture.init(rawValue:)) else {
            throw XcodeArchError.invalidArchitecture(String(describing: machineArch))
        }
        if case .x86_64 = machineArch {
            throw XcodeArchError.runningInX86_64
        }
    }
}

// MARK: -
extension Architecture: ExpressibleByArgument {
}

