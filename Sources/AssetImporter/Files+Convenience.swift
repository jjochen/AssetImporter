import Files
import Foundation

internal extension Folder {
    init(path: String, createIfNeeded: Bool) throws {
        if createIfNeeded {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
        try self.init(path: path)
    }

    func filePath(forFileWithName fileName: String, fileExtension: String) -> String {
        return url.appendingPathComponent(fileName).appendingPathExtension(fileExtension).path
    }

    func fileMapping(forFilesWithExtension fileExtension: String) throws -> [String: File] {
        var mapping: [String: File] = [:]
        try files.recursive.enumerated().forEach { _, file in
            guard file.extension == fileExtension else {
                return
            }
            let fileName = file.nameExcludingExtension
            guard mapping[fileName] == nil else {
                throw AssetImporterError.multipleFilesWithName(name: fileName, path: path)
            }
            mapping[fileName] = file
        }
        return mapping
    }
}

internal extension File {
    func replace(withFile file: File) throws {
        guard let parent = parent else {
            throw AssetImporterError.unknown(message: "file has no no parent")
        }
        try delete()
        try file.copy(to: parent)
    }
}
