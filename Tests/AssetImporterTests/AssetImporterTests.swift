@testable import AssetImporter
import XCTest

final class AssetImporterTests: XCTestCase {
    func testErrorHasDescription() {
        XCTAssertFalse(AssetImporterError.noFilesFound(extension: "json", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.multipleFilesWithName(name: "name", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.unknown.description.isEmpty)
    }

    static var allTests = [
        ("testErrorHasDescription", testErrorHasDescription),
    ]
}
