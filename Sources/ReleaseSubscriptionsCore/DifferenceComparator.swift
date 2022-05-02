//
//  DifferenceComparator.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/04.
//

import Foundation
import Logging

public struct DifferenceComparator {
    public static func insertions(repositories: [GitHubRepository], old: [GitHubRepository : [Release]], new: [GitHubRepository : [Release]]) -> [GitHubRepository : [Release]] {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        var insertions: [GitHubRepository : [Release]] = [:]
        for repository in repositories {
            guard let oldReleases = old[repository] else {
                Logger.shared.info("🔔 No older release information on \(repository.name) was found")
                continue
            }
            let newReleases = new[repository] ?? []
            insertions[repository] = newReleases.difference(from: oldReleases).insertions.compactMap {
                if case CollectionDifference<Release>.Change.insert(_, let element,  _) = $0 {
                    return element
                } else {
                    return nil
                }
            }
            if insertions[repository]?.isEmpty ?? true {
                Logger.shared.info("💤 There are no differences in \(repository.name) releases")
            } else {
                Logger.shared.info("🤩 There are differences in \(repository.name) releases")
            }
        }
        return insertions
    }
}
