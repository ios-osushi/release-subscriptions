//
//  Fetcher.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/02.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

public struct Fetcher {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static func fetch(repository: GitHubRepository) async throws -> [Release] {
        Logger.shared.info("ℹ️ Fetching \(repository.apiURL)")
        let url = repository.apiURL
        let (data, _) = try await URLSession.shared.data(from: url)
        let releases = try decoder.decode([Release].self, from: data)
        Logger.shared.info("✅ Fetched \(repository.apiURL)")
        return releases
    }
    
    public static func fetch(repositories: [GitHubRepository]) async throws -> [GitHubRepository : [Release]] {
        Logger.shared.info("ℹ️ \(#function) started.")
        return try await withThrowingTaskGroup(of: (GitHubRepository, [Release]).self) { group in
            for repository in repositories {
                group.addTask {
                    let releases = try await fetch(repository: repository)
                    return (repository, releases)
                }
            }
            
            var results: [GitHubRepository : [Release]] = [:]
            for try await (repository, releases) in group {
                results[repository] = releases
            }
            return results
        }
    }
}
