//
//  FileHelper.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/03.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct FileHelper {
    static let RFC3339DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = .init(identifier: "Asia/Tokyo")
        return formatter
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(RFC3339DateFormatter)
        return decoder
    }()
    
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(RFC3339DateFormatter)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }()
    
    static let manager = FileManager.default
    
    static var outputURL: URL {
        get throws {
            let outputURL = URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Outputs", isDirectory: true)
            if !manager.fileExists(atPath: outputURL.path) {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true)
            }
            return outputURL
        }
    }
    
    public static func load(repositories: [GitHubRepository]) throws -> [GitHubRepository : [Release]] {
        var contents: [GitHubRepository : [Release]] = [:]
        for repository in repositories {
            let url = try outputURL.appendingPathComponent(repository.outputJSONFileName)
            do {
                let data = try Data(contentsOf: url)
                let releases = try decoder.decode([Release].self, from: data)
                contents[repository] = releases
            } catch CocoaError.fileReadNoSuchFile {
                // skip
            } catch let nsError as NSError where nsError.domain == NSPOSIXErrorDomain && nsError.code == POSIXError.ENOENT.rawValue {
                // skip
            }
        }
        return contents
    }
    
    public static func save(contents: [GitHubRepository : [Release]]) throws {
        for (repositry, releases) in contents {
            let url = try outputURL.appendingPathComponent(repositry.outputJSONFileName)
            let data = try encoder.encode(releases)
            try data.write(to: url)
        }
    }
}
