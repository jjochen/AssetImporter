@testable import AssetImporter
import Files
import Foundation
import XCTest

final class AssetImporterTests: XCTestCase {
    var importer: AssetImporter!
    var testFolder: TestFolder!
    var svgFolder: Folder!
    var pdfFolder: Folder!
    var newItemsSubfolder = "new"
    var catalogFolder: Folder!

    override func setUp() {
        super.setUp()
        do {
            testFolder = try TestFolder()
            let workFolder = testFolder.workFolder
            svgFolder = try workFolder.createSubfolderIfNeeded(at: "svg")
            pdfFolder = try workFolder.createSubfolderIfNeeded(at: "pdf")
            catalogFolder = try workFolder.createSubfolderIfNeeded(at: "assets.xcassets")
            importer = try AssetImporter(originSVGFolderPath: svgFolder.path,
                                         assetsCatalogPath: catalogFolder.path,
                                         intermediatePDFFolderPath: pdfFolder.path,
                                         newAssetsSubfolderName: newItemsSubfolder)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        do {
            try testFolder.delete()
        } catch {
            XCTFail(error.localizedDescription)
        }
        super.tearDown()
    }
}

extension AssetImporterTests {
    func testImporterNotNil() {
        XCTAssertNotNil(importer)
    }

    func testImporterCopiesNewFilesToNewItemsFolder() {
        do {
            try testFolder.file(forResource: .add16ptRoundedSVG).copy(to: svgFolder)
            try testFolder.file(forResource: .add16ptSVG).copy(to: svgFolder)
            try testFolder.file(forResource: .add16ptRoundedPDF).copy(to: catalogFolder)
            let result = try importer.importAssets(withDefaultScale: 0.5, importAll: false)
            XCTAssertEqual(result.new, 1)
            XCTAssertEqual(result.skipped, 1)
            XCTAssertEqual(result.replaced, 0)
            XCTAssert(catalogFolder.containsFile(at: "new/add_16pt.imageset/add_16pt.pdf"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testImporterImportsAllWhenForced() {
        do {
            try testFolder.file(forResource: .add16ptRoundedSVG).copy(to: svgFolder)
            try testFolder.file(forResource: .add16ptSVG).copy(to: svgFolder)
            try testFolder.file(forResource: .add16ptRoundedPDF).copy(to: catalogFolder)
            let result = try importer.importAssets(withDefaultScale: 0.5, importAll: true)
            XCTAssertEqual(result.new, 1)
            XCTAssertEqual(result.skipped, 0)
            XCTAssertEqual(result.replaced, 1)
            XCTAssert(catalogFolder.containsFile(at: "new/add_16pt.imageset/add_16pt.pdf"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testIconSizeFromFileName() {
        XCTAssertEqual(importer.iconSize(forFile: "icon_24pt.svg"), CGSize(width: 24, height: 24))
        XCTAssertEqual(importer.iconSize(forFile: "icon_20pt_rounded.svg"), CGSize(width: 20, height: 20))
        XCTAssertEqual(importer.iconSize(forFile: "icon_21pt"), CGSize(width: 21, height: 21))
        XCTAssertNil(importer.iconSize(forFile: "icon_24px.svg"))
        XCTAssertNil(importer.iconSize(forFile: "icon_0pt.svg"))
    }

    func testImageSetCreation() {
        do {
            let asset = try testFolder.file(forResource: .add16ptRoundedPDF)
            try importer.createNewAssetsCatalogEntry(withAsset: asset)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension AssetImporterTests {
    static var allTests = [
        ("testImporterNotNil", testImporterNotNil),
        ("testImporterCopiesNewFilesToNewItemsFolder", testImporterCopiesNewFilesToNewItemsFolder),
        ("testImporterImportsAllWhenForced", testImporterImportsAllWhenForced),
        ("testIconSizeFromFileName", testIconSizeFromFileName),
    ]
}
