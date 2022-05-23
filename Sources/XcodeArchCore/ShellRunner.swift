import Foundation

public protocol ShellRunner {
    @discardableResult
    static func run(_ launchPath: String,
                    with arguments: [String]) throws -> Pipe
}

public extension ShellRunner {
    @discardableResult
    static func run(_ launchPath: String) throws -> Pipe {
        try run(launchPath, with: [])
    }
}

public struct DefaultShellRunner: ShellRunner {
    @discardableResult
    public static func run(_ launchPath: String,
                    with arguments: [String]) throws -> Pipe {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()

        return pipe
    }
}

public extension Pipe {
    var stringOutput: String? {
        let data = fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .newlines)
    }
}
