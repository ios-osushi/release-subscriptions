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

public struct Fetcher {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static func fetch(repository: GitHubRepository) async throws -> [Release] {
        let url = repository.apiURL
        let (data, _) = try await URLSession.shared.data(from: url)
        let releases = try decoder.decode([Release].self, from: data)
        return releases
    }
    
    public static func fetch(repositories: [GitHubRepository]) async throws -> [GitHubRepository : [Release]] {
        try await withThrowingTaskGroup(of: (GitHubRepository, [Release]).self) { group in
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
