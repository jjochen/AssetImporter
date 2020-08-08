//
//  CommandLineTask.swift
//  ArgumentParser
//
//  Created by Jochen on 06.08.20.
//

import Foundation

internal struct CommandLineTask {
    private static let launchPathImageMagick = "/usr/local/bin/magick"
    private static let launchPathRSVG = "/usr/local/bin/rsvg-convert"

    static func image(at origin: String, isEqualToImageAt destination: String) -> Bool {
        let arguments = ["compare", "-metric", "AE", "\(origin)", "\(destination)", "/tmp/difference.pdf"]
        let result = runProcess(withExecutablePath: launchPathImageMagick, arguments: arguments)
        return result.success && Int(result.error) == 0
    }

    static func scaleSVG(at origin: String, destination: String, size: CGSize? = nil, scale: Float) {
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
        runProcess(withExecutablePath: launchPathRSVG, arguments: arguments)
        // ToDo throw Error
    }
}

private extension CommandLineTask {
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
