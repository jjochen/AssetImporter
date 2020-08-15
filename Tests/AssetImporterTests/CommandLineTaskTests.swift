//
//  CommandLineTaskTests.swift
//  ArgumentParser
//
//  Created by Jochen on 08.08.20.
//

@testable import AssetImporter
import Files
import Foundation
import XCTest

final class CommandLineTaskTests: XCTestCase {
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

    func testResourcesReadable() {
        XCTAssertNotNil(try testFolder.file(forResource: .add16ptSVG))
        XCTAssertNotNil(try testFolder.file(forResource: .add16ptRoundedSVG))
        XCTAssertNotNil(try testFolder.file(forResource: .add16ptRoundedPDF))
    }

    func testScaleSVGTask() {
        do {
            let origin = try testFolder.filePath(forResource: .add16ptSVG)
            let destination = testFolder.filePathInWorkFolder(forFileNamed: "file1.pdf")
            try CommandLineTask.scaleSVG(at: origin,
                                         destination: destination,
                                         size: CGSize(width: 16, height: 16),
                                         scale: 1)
            XCTAssert(FileManager.default.fileExists(atPath: destination))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testScaleSVGTaskThrowsError() {
        do {
            let origin = try testFolder.filePath(forResource: .add16ptSVG)
            let destination = testFolder.filePathInWorkFolder(forFileNamed: "does_not_exist/file1.pdf")
            XCTAssertThrowsError(try CommandLineTask.scaleSVG(at: origin,
                                                              destination: destination,
                                                              size: CGSize(width: 16, height: 16),
                                                              scale: 1))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testRoundedSVGIsEqualToRoundedPDF() {
        do {
            let svgPath1 = try testFolder.filePath(forResource: .add16ptRoundedSVG)
            let pdfPath1 = testFolder.filePathInWorkFolder(forFileNamed: "test.pdf")
            let pdfPath2 = try testFolder.filePath(forResource: .add16ptRoundedPDF)
            try CommandLineTask.scaleSVG(at: svgPath1, destination: pdfPath1, scale: 0.5)
            let isEqual = CommandLineTask.image(at: pdfPath1, isEqualToImageAt: pdfPath2)
            XCTAssert(isEqual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testRoundedSVGIsEqualToRoundedSVG() {
        do {
            let svgPath = try testFolder.filePath(forResource: .add16ptRoundedSVG)
            let pdfPath1 = testFolder.filePathInWorkFolder(forFileNamed: "rounded1.pdf")
            let pdfPath2 = testFolder.filePathInWorkFolder(forFileNamed: "rounded2.pdf")
            try CommandLineTask.scaleSVG(at: svgPath, destination: pdfPath1, scale: 0.5)
            try CommandLineTask.scaleSVG(at: svgPath, destination: pdfPath2, scale: 0.5)
            let isEqual = CommandLineTask.image(at: pdfPath1, isEqualToImageAt: pdfPath2)
            XCTAssert(isEqual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testRoundedSVGIsNotEqualToNoneRoundedSVG() {
        do {
            let svgPath1 = try testFolder.filePath(forResource: .add16ptSVG)
            let svgPath2 = try testFolder.filePath(forResource: .add16ptRoundedSVG)
            let pdfPath1 = testFolder.filePathInWorkFolder(forFileNamed: "not_rounded.pdf")
            let pdfPath2 = testFolder.filePathInWorkFolder(forFileNamed: "rounded.pdf")
            try CommandLineTask.scaleSVG(at: svgPath1, destination: pdfPath1, scale: 0.5)
            try CommandLineTask.scaleSVG(at: svgPath2, destination: pdfPath2, scale: 0.5)
            let isEqual = CommandLineTask.image(at: pdfPath1, isEqualToImageAt: pdfPath2)
            XCTAssertFalse(isEqual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testImagesWithDifferentSizeAreNotEqual() {
        do {
            let svgPath = try testFolder.filePath(forResource: .add16ptRoundedSVG)
            let pdfPath1 = testFolder.filePathInWorkFolder(forFileNamed: "file1.pdf")
            let pdfPath2 = testFolder.filePathInWorkFolder(forFileNamed: "file2.pdf")
            try CommandLineTask.scaleSVG(at: svgPath, destination: pdfPath1, scale: 0.5)
            try CommandLineTask.scaleSVG(at: svgPath, destination: pdfPath2, scale: 0.6)
            let isEqual = CommandLineTask.image(at: pdfPath1, isEqualToImageAt: pdfPath2)
            XCTAssertFalse(isEqual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension CommandLineTaskTests {
    static var allTests = [
        ("testResourcesReadable", testResourcesReadable),
        ("testScaleSVGTask", testScaleSVGTask),
        ("testScaleSVGTaskThrowsError", testScaleSVGTaskThrowsError),
        ("testRoundedSVGIsEqualToRoundedPDF", testRoundedSVGIsEqualToRoundedPDF),
        ("testRoundedSVGIsEqualToRoundedSVG", testRoundedSVGIsEqualToRoundedSVG),
        ("testRoundedSVGIsNotEqualToNoneRoundedSVG", testRoundedSVGIsNotEqualToNoneRoundedSVG),
        ("testImagesWithDifferentSizeAreNotEqual", testImagesWithDifferentSizeAreNotEqual),
    ]
}
