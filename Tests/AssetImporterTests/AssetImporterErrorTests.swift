@testable import AssetImporter
import Foundation
import XCTest

final class AssetImporterErrorTests: XCTestCase {
    func testErrorHasDescription() {
        XCTAssertFalse(AssetImporterError.noFilesFound(extension: "json", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.multipleFilesWithName(name: "name", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.commandLineError(message: "some message").description.isEmpty)
        XCTAssertFalse(AssetImporterError.unknown(message: "some message").description.isEmpty)
    }
}

extension AssetImporterErrorTests {
    static var allTests = [
        ("testErrorHasDescription", testErrorHasDescription),
    ]
}
