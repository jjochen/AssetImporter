@testable import AssetImporter
import XCTest
import Foundation
import Files

final class AssetImporterTests: XCTestCase {
    func testErrorHasDescription() {
        XCTAssertFalse(AssetImporterError.noFilesFound(extension: "json", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.multipleFilesWithName(name: "name", path: "/some/path").description.isEmpty)
        XCTAssertFalse(AssetImporterError.unknown.description.isEmpty)
    }

    func testResourcesReadable() {
        do {
            let testFolder = try TestFolder()
            XCTAssertNotNil(try testFolder.file(forResource: .add16ptSVG))
            XCTAssertNotNil(try testFolder.file(forResource: .add16ptRoundedSVG))
            try testFolder.delete()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testConvertion() {
        do {
            let testFolder = try TestFolder()
            let originFile = try testFolder.file(forResource: .add16ptSVG)
            let destination = testFolder.workFolder.url.appendingPathComponent("file1.pdf").path
            XCTAssert(Tasks.scaleSVG(at: originFile.path, destination: destination, size: CGSize(width: 16, height: 16), scale: 1))
            XCTAssert(FileManager.default.fileExists(atPath: destination))
            try testFolder.delete()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testErrorHasDescription", testErrorHasDescription),
    ]
}
