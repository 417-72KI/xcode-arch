import Foundation
import XcodeArchCore

final class MockShellRunner: ShellRunner {
    private(set) static var receivedCommands: [String] = []
    private(set) static var outputs: [String: String] = [:]

    static func run(_ launchPath: String,
                    with arguments: [String]) throws -> Pipe {
        let command = receivedCommand(launchPath, arguments: arguments)
        guard let output = outputs[command] else { return Pipe() }
        receivedCommands.append(command) 
        let pipe = Pipe()
        let process = Process()
        process.standardOutput = pipe
        process.executableURL = URL(fileURLWithPath: "/bin/echo")
        process.arguments = [output]
        try process.run()
        process.waitUntilExit()
        return pipe
    }
}

private extension MockShellRunner {
    static func receivedCommand(_ command: String, arguments: [String]) -> String {
        ([command] + arguments).joined(separator: " ")
    }
}

extension MockShellRunner {
    static func register(command: String, withOutput output: String = "") {
        outputs[command] = output
    }

    static func reset() {
        receivedCommands = []
        outputs = [:]
    }
}
