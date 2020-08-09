@testable import AssetImporter
import Files
import Foundation
import XCTest

final class AssetImporterTests: XCTestCase {
    var importer = AssetImporter()

    func testErrorHasDescription() {
        XCTAssertFalse(AssetImporterError.noFilesFound(extension: "json", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.multipleFilesWithName(name: "name", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.commandLineError(message: "some message").description.isEmpty)
        XCTAssertFalse(AssetImporterError.unknown(message: "some message").description.isEmpty)
    }

    func testIconSizeFromFileName() {
        XCTAssertEqual(AssetImporter.iconSize(forFile: "icon_24pt.svg"), CGSize(width: 24, height: 24))
        XCTAssertEqual(AssetImporter.iconSize(forFile: "icon_20pt_rounded.svg"), CGSize(width: 20, height: 20))
        XCTAssertEqual(AssetImporter.iconSize(forFile: "icon_21pt"), CGSize(width: 21, height: 21))
    }

    static var allTests = [
        ("testErrorHasDescription", testErrorHasDescription),
        ("testIconSizeFromFileName", testIconSizeFromFileName),
    ]
}
