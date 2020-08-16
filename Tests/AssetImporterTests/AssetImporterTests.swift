@testable import AssetImporter
import Files
import Foundation
import XCTest

final class AssetImporterTests: XCTestCase {
    var importer: AssetImporter!
    var testFolder: TestFolder!
    var svgFolder: Folder!
    var pdfFolder: Folder!
    var newItemsFolder: Folder!
    var catalogFolder: Folder!

    override func setUp() {
        super.setUp()
        do {
            testFolder = try TestFolder()
            let workFolder = testFolder.workFolder
            svgFolder = try workFolder.createSubfolderIfNeeded(at: "svg")
            pdfFolder = try workFolder.createSubfolderIfNeeded(at: "pdf")
            newItemsFolder = try workFolder.createSubfolderIfNeeded(at: "new")
            catalogFolder = try workFolder.createSubfolderIfNeeded(at: "assets.xcassets")
            importer = try AssetImporter(originSVGFolderPath: svgFolder.path,
                                         assetCatalogPath: catalogFolder.path,
                                         intermediatePDFFolderPath: pdfFolder.path,
                                         newAssetsFolderPath: newItemsFolder.path)
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
            XCTAssertEqual(result.imported, 0)
            XCTAssert(newItemsFolder.containsFile(named: "add_16pt.pdf"))
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
            XCTAssertEqual(result.imported, 1)
            XCTAssert(newItemsFolder.containsFile(named: "add_16pt.pdf"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testFilePathMapping() {
        do {
            let file1 = try testFolder.file(forResource: .add16ptRoundedSVG)
            try file1.copy(to: svgFolder)
            let file2 = try testFolder.file(forResource: .add16ptSVG)
            try file2.copy(to: svgFolder)
            let file3 = try testFolder.file(forResource: .add16ptRoundedPDF)
            try file3.copy(to: svgFolder)
            let mapping = try importer.filePathMapping(forFolder: svgFolder, fileExtension: "svg")
            XCTAssertEqual(mapping.count, 2)
            XCTAssertNotNil(mapping[file1.nameExcludingExtension])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testFilePathMappingThrowsForEmptyFolder() {
        do {
            let file1 = try testFolder.file(forResource: .add16ptRoundedSVG)
            try file1.copy(to: svgFolder)
            let subfolder = try svgFolder.createSubfolder(at: "subfolder")
            try file1.copy(to: subfolder)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertThrowsError(_ = try importer.filePathMapping(forFolder: svgFolder, fileExtension: "svg"))
    }

    func testFilePathMappingThrowsForDuplicateFile() {
        XCTAssertThrowsError(_ = try importer.filePathMapping(forFolder: svgFolder, fileExtension: "svg"))
    }

    func testIconSizeFromFileName() {
        XCTAssertEqual(importer.iconSize(forFile: "icon_24pt.svg"), CGSize(width: 24, height: 24))
        XCTAssertEqual(importer.iconSize(forFile: "icon_20pt_rounded.svg"), CGSize(width: 20, height: 20))
        XCTAssertEqual(importer.iconSize(forFile: "icon_21pt"), CGSize(width: 21, height: 21))
        XCTAssertNil(importer.iconSize(forFile: "icon_24px.svg"))
        XCTAssertNil(importer.iconSize(forFile: "icon_0pt.svg"))
    }
}

extension AssetImporterTests {
    static var allTests = [
        ("testImporterNotNil", testImporterNotNil),
        ("testIconSizeFromFileName", testIconSizeFromFileName),
    ]
}
