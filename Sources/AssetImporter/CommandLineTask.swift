import Foundation

internal struct CommandLineTask {
    private static let launchPathImageMagick = "/usr/local/bin/magick"
    private static let launchPathRSVG = "/usr/local/bin/rsvg-convert"

    static func image(at origin: String, isEqualToImageAt destination: String) -> Bool {
        let arguments = ["compare", "-metric", "AE", "\(origin)", "\(destination)", "/tmp/difference.pdf"]
        let result = runProcess(withExecutablePath: launchPathImageMagick, arguments: arguments)
        return result.success && Int(result.error) == 0
    }

    static func scaleSVG(at origin: String, destination: String, size: CGSize? = nil, scale: Float) throws {
        var arguments: [String] = []
        arguments.append("\(origin)")
        arguments.append("--output=\(destination)")
        arguments.append("--keep-aspect-ratio")
        arguments.append("--format=pdf")
        if let size = size {
            arguments.append("--width=\(Int(size.width))")
            arguments.append("--height=\(Int(size.height))")
        } else {
            arguments.append("--zoom=\(scale)")
        }
        let result = runProcess(withExecutablePath: launchPathRSVG, arguments: arguments)
        if !result.success {
            throw AssetImporterError.commandLineError(message: result.error)
        }
    }

    static func checkExternalDependencies() throws {
        try ensureAvailability(ofCommand: launchPathImageMagick)
        try ensureAvailability(ofCommand: launchPathRSVG)
    }
}

private extension CommandLineTask {
    static func ensureAvailability(ofCommand command: String) throws {
        let arguments = ["--version"]
        let result = runProcess(withExecutablePath: command, arguments: arguments)
        if !result.success {
            throw AssetImporterError.commandLineError(message: result.error)
        }
    }

    @discardableResult
    private static func runProcess(withExecutablePath path: String,
                                   arguments: [String]?) -> (success: Bool, output: String, error: String) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.launch()
        process.waitUntilExit()
        let success = process.terminationStatus == 0
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(decoding: errorData, as: UTF8.self)
        return (success, output, error)
    }
}
