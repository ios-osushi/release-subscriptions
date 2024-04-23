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
    
    static func fetch(repository: GitHubRepository, apiToken: String?) async throws -> [Release] {
        Logger.shared.info("ℹ️ Fetching \(repository.apiURL)")
        var request = URLRequest(url: repository.apiURL)
        if let apiToken {
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(apiToken)"
            ]
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        do {
            let releases = try decoder.decode([Release].self, from: data)
            Logger.shared.info("✅ Fetched \(repository.apiURL)")
            return releases
        } catch {
            print(String(data: data, encoding: .utf8) ?? "")
            throw error
        }
    }
    
    public static func fetch(repositories: [GitHubRepository], apiToken: String?) async throws -> [GitHubRepository : [Release]] {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        return try await withThrowingTaskGroup(of: (GitHubRepository, [Release]).self) { group in
            for repository in repositories {
                group.addTask {
                    do {
                        let releases = try await fetch(repository: repository, apiToken: apiToken)
                        return (repository, releases)
                    } catch {
                        Logger.shared.error("❌ \(#function) failed \(error)")
                        Logger.shared.error("❌ repository: \(repository)")
                        throw error
                    }
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
