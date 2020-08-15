@testable import AssetImporter
import Foundation
import XCTest

final class AssetImporterTests: XCTestCase {
    func testIconSizeFromFileName() {
        XCTAssertEqual(AssetImporter.iconSize(forFile: "icon_24pt.svg"), CGSize(width: 24, height: 24))
        XCTAssertEqual(AssetImporter.iconSize(forFile: "icon_20pt_rounded.svg"), CGSize(width: 20, height: 20))
        XCTAssertEqual(AssetImporter.iconSize(forFile: "icon_21pt"), CGSize(width: 21, height: 21))
    }
}

extension AssetImporterTests {
    static var allTests = [
        ("testIconSizeFromFileName", testIconSizeFromFileName),
    ]
}
