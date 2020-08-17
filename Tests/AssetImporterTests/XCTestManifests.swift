import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(AssetImporterTests.allTests),
            testCase(CommandLineTaskTests.allTests),
            testCase(AssetImporterErrorTests.allTests),
        ]
    }
#endif
