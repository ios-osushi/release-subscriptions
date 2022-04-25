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
import Logging

public struct FileHelper {
    enum Error: Swift.Error {
        case invalidREADMEFormat
    }
    
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
            let outputURL = URL.topLevelDirectory.appendingPathComponent("Outputs", isDirectory: true)
            if !manager.fileExists(atPath: outputURL.path) {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true)
            }
            return outputURL
        }
    }
    
    // MARK: - Repositories and Releases
    
    public static func load(repositories: [GitHubRepository]) throws -> [GitHubRepository : [Release]] {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        var contents: [GitHubRepository : [Release]] = [:]
        for repository in repositories {
            Logger.shared.info("ℹ️ Loading \(repository.outputJSONFileName)")
            let url = try outputURL.appendingPathComponent(repository.outputJSONFileName)
            do {
                let data = try Data(contentsOf: url)
                let releases = try decoder.decode([Release].self, from: data)
                contents[repository] = releases
                Logger.shared.info("✅ Successfully loaded \(repository.outputJSONFileName)")
            } catch CocoaError.fileReadNoSuchFile {
                Logger.shared.info("🔔 \(repository.outputJSONFileName) loading was skipped because that file could not be found")
            } catch let nsError as NSError where nsError.domain == NSPOSIXErrorDomain && nsError.code == POSIXError.ENOENT.rawValue {
                Logger.shared.info("🔔 \(repository.outputJSONFileName) loading was skipped because that file could not be found")
            }
        }
        return contents
    }
    
    public static func save(contents: [GitHubRepository : [Release]]) throws {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        for (repository, releases) in contents {
            Logger.shared.info("ℹ️ Saving \(repository.outputJSONFileName)")
            let url = try outputURL.appendingPathComponent(repository.outputJSONFileName)
            let data = try encoder.encode(releases)
            try data.write(to: url)
            Logger.shared.info("✅ Saved \(repository.outputJSONFileName)")
        }
    }
    
    
    // MARK: - README.md
    
    private static let lowerBoundKeyword = "<!-- BEGIN LIST OF REPOSITORIES (AUTOMATICALLY OUTPUT) -->"
    private static let upperBoundKeyword = "<!-- END LIST OF REPOSITORIES (AUTOMATICALLY OUTPUT) -->"
    public static func writeToREADME(repositories: [GitHubRepository]) throws {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        let (url, string, lowerBound, upperBound) = try readFromREADME()
        let outputListOfRepositoriesString = """
        \(lowerBoundKeyword)
        |名前|リポジトリ|スター数|ウォッチ数|
        |:--|:--|:--|:--|
        
        """
        + repositories.map {
            let repository = "\($0.owner)/\($0.repository)"
            return "|\($0.name)|[\(repository)](https://github.com/\(repository))|[![GitHub Repo stars](https://img.shields.io/github/stars/\(repository)?style=social)](https://github.com/\(repository)/stargazers)|[![GitHub watchers](https://img.shields.io/github/watchers/\(repository)?style=social)](https://github.com/\(repository)/watchers)|\n"
        }.joined()
        + upperBoundKeyword
        try string.replacingCharacters(in: lowerBound..<upperBound, with: outputListOfRepositoriesString)
            .write(to: url, atomically: true, encoding: .utf8)
    }
    
    static func readFromREADME() throws -> (URL, String, String.Index, String.Index) {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        let url = URL.topLevelDirectory.appendingPathComponent("README.md")
        let string = try String(contentsOf: url)
        guard let lowerBound = string.range(of: lowerBoundKeyword)?.lowerBound,
              let upperBound = string.range(of: upperBoundKeyword)?.upperBound else {
            throw Error.invalidREADMEFormat
        }
        return (url, string, lowerBound, upperBound)
    }
}
