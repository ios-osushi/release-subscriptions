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
        do {
            Logger.shared.info("ℹ️ Fetching \(repository.apiURL)")
            let url = repository.apiURL
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                Logger.shared.info("✅ Fetched \(repository.apiURL)")
                let releases = try decoder.decode([Release].self, from: data)
                Logger.shared.info("✅ Parsed \(repository.apiURL)")
                return releases
            } catch {
                Logger.shared.info("❌ Parse failed \(repository.apiURL), error: \(error), data: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw error
            }
        } catch {
            Logger.shared.info("❌ Fetch failed \(repository.apiURL), error: \(error)")
            throw error
        }
    }
    
    public static func fetch(repositories: [GitHubRepository]) async throws -> [GitHubRepository : [Release]] {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        return try await withThrowingTaskGroup(of: (GitHubRepository, [Release]).self) { group in
            for repository in repositories {
                group.addTask {
                    do {
                        let releases = try await fetch(repository: repository)
                        return (repository, releases)
                    } catch {
                        Logger.shared.error("❌ \(#function) failed")
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
