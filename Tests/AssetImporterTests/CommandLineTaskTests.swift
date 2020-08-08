//
//  CommandLineTaskTests.swift
//  ArgumentParser
//
//  Created by Jochen on 08.08.20.
//

@testable import AssetImporter
import XCTest
import Foundation
import Files

final class CommandLineTaskTests: XCTestCase {
    var testFolder: TestFolder!

    override func setUp() {
        super.setUp()
        self.testFolder = try? TestFolder()
    }

    override func tearDown() {
        try! self.testFolder.delete()
        super.tearDown()
    }

    func testResourcesReadable() {
            XCTAssertNotNil(try testFolder.file(forResource: .add16ptSVG))
            XCTAssertNotNil(try testFolder.file(forResource: .add16ptRoundedSVG))

    }

    func testScaleSVGTask() {
        do {
            let origin = try testFolder.filePath(forResource: .add16ptSVG)
            let destination = testFolder.filePathInWorkFolder(forFileNamed: "file1.pdf")
            CommandLineTask.scaleSVG(at: origin,
                                     destination: destination,
                                     size: CGSize(width: 16, height: 16),
                                     scale: 1)
            XCTAssert(FileManager.default.fileExists(atPath: destination))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testResourcesReadable", testResourcesReadable),
        ("testScaleSVGTask", testScaleSVGTask),
    ]
}
