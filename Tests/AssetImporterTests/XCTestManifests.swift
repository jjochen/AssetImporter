import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(AssetImporterTests.allTests),
            testCase(AssetImporterErrorTests.allTests),
            testCase(CommandLineTaskTests.allTests),
        ]
    }
#endif
