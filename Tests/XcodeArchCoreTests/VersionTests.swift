import XCTest
import XCTest
import struct XcodeArchCore.Version

final class VersionTests: XCTestCase {
    func testStringLiteral() {
        XCTAssertEqual("1.4", Version(1, 4, 0))
        XCTAssertEqual("v2.8.9", Version(2, 8, 9))
        XCTAssertEqual("2.8.2-alpha", Version(2, 8, 2, preRelease: "alpha"))
        XCTAssertEqual("2.8.2-alpha+build234", Version(2, 8, 2, preRelease: "alpha", buildMetadata: "build234"))
        XCTAssertEqual("2.8.2+build234", Version(2, 8, 2, buildMetadata: "build234"))
        XCTAssertEqual("2.8.2-alpha.2.1.0", Version(2, 8, 2, preRelease: "alpha.2.1.0"))
    }

    func testDescription() {
        XCTAssertEqual(Version(1, 4, 0).description, "1.4.0")
        XCTAssertEqual(Version(2, 8, 9).description, "2.8.9")
        XCTAssertEqual(Version(2, 8, 2, preRelease: "alpha").description, "2.8.2-alpha")
        XCTAssertEqual(Version(2, 8, 2, preRelease: "alpha", buildMetadata: "build234").description, "2.8.2-alpha+build234")
        XCTAssertEqual(Version(2, 8, 2, buildMetadata: "build234").description, "2.8.2+build234")
        XCTAssertEqual(Version(2, 8, 2, preRelease: "alpha.2.1.0").description, "2.8.2-alpha.2.1.0")
    }

    func testCompare() {
        XCTAssertLessThan(Version(1, 0, 0), Version(1, 0, 1))
        XCTAssertLessThan(Version(1, 4, 0), "1.4.1")
        XCTAssertGreaterThan(Version(1, 5, 0), "1.4.1")
        XCTAssertGreaterThan("2.0.0", Version(1, 4, 1))
        XCTAssertLessThan(Version(2, 0, 0, preRelease: "alpha"), "2.0.0")
        XCTAssertGreaterThan("2.0.1-alpha", Version(2, 0, 0))
    }
}
