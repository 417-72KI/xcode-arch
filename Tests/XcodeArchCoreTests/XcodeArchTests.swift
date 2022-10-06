import XCTest
@testable import XcodeArchCore

final class XcodeArchTests: XCTestCase {
    override class func setUp() {
        XcodeArch.shellRunner = MockShellRunner.self
    }

    override func setUpWithError() throws {
        MockShellRunner.reset()
    }

    func testGetCurrentXcodePath() async throws {
        MockShellRunner.register(command: "/usr/bin/xcode-select -p", withOutput: "/Applications/Xcode.app/Contents/Developer")
        let path = try await XcodeArch.getCurrentXcodePath()
        XCTAssertEqual(MockShellRunner.receivedCommands, ["/usr/bin/xcode-select -p"])
        XCTAssertEqual(path, "/Applications/Xcode.app")
    }

    func testLaunchXcode() async throws {
        MockShellRunner.register(command: "/usr/bin/xcode-select -p", withOutput: "/Applications/Xcode.app/Contents/Developer")
        MockShellRunner.register(command: "/usr/bin/open /Applications/Xcode.app")
        try await XcodeArch.launchXcode()
        XCTAssertEqual(MockShellRunner.receivedCommands, [
            "/usr/bin/xcode-select -p",
            "/usr/bin/open /Applications/Xcode.app"
        ])
    }

    func testLaunchXcodeWithPath() async throws {
        MockShellRunner.register(command: "/usr/bin/open /Applications/Xcode.app")
        try await XcodeArch.launchXcode(withPath: "/Applications/Xcode.app")
        XCTAssertEqual(MockShellRunner.receivedCommands, ["/usr/bin/open /Applications/Xcode.app"])
    }

    func testKillXcode() async throws {
        MockShellRunner.register(command: "/usr/bin/killall Xcode")
        try await XcodeArch.killXcode()
        XCTAssertEqual(MockShellRunner.receivedCommands, ["/usr/bin/killall Xcode"])
    }
}
