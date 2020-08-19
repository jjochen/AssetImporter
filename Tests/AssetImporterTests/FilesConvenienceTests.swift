//
//  File.swift
//
//
//  Created by Jochen on 19.08.20.
//

@testable import AssetImporter
import Files
import Foundation
import XCTest

final class FilesConvenienceTests: XCTestCase {
    var testFolder: TestFolder!

    override func setUp() {
        super.setUp()
        do {
            testFolder = try TestFolder()
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

extension FilesConvenienceTests {
    func testFileMapping() {
        do {
            let file1 = try testFolder.file(forResource: .add16ptRoundedSVG)
            try file1.copy(to: testFolder.workFolder)
            let file2 = try testFolder.file(forResource: .add16ptSVG)
            try file2.copy(to: testFolder.workFolder)
            let file3 = try testFolder.file(forResource: .add16ptRoundedPDF)
            try file3.copy(to: testFolder.workFolder)
            let mapping = try testFolder.workFolder.fileMapping(forFilesWithExtension: "svg")
            XCTAssertEqual(mapping.count, 2)
            XCTAssertNotNil(mapping[file1.nameExcludingExtension])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testFileMappingThrowsForDuplicateFile() {
        do {
            let file1 = try testFolder.file(forResource: .add16ptRoundedSVG)
            try file1.copy(to: testFolder.workFolder)
            let subfolder = try testFolder.workFolder.createSubfolder(at: "subfolder")
            try file1.copy(to: subfolder)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertThrowsError(_ = try testFolder.workFolder.fileMapping(forFilesWithExtension: "svg"))
    }
}

extension FilesConvenienceTests {
    static var allTests = [
        ("testFileMapping", testFileMapping),
        ("testFileMappingThrowsForDuplicateFile", testFileMappingThrowsForDuplicateFile),
    ]
}
