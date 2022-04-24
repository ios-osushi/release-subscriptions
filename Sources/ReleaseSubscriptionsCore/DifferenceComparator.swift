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
        Logger.shared.info("ℹ️ \(#function) started.")
        var insertions: [GitHubRepository : [Release]] = [:]
        for repository in repositories {
            guard let oldReleases = old[repository] else {
                Logger.shared.notice("🔔 No older release information on \(repository.name) was found.")
                continue
            }
            let newReleases = new[repository] ?? []
            insertions[repository] = newReleases.difference(from: oldReleases).insertions.compactMap {
                if case CollectionDifference<Release>.Change.insert(_, let element,  _) = $0 {
                    Logger.shared.info("🤩 There are differences in \(repository.name) releases")
                    return element
                } else {
                    Logger.shared.info("💤 There are no differences in \(repository.name) releases")
                    return nil
                }
            }
        }
        return insertions
    }
}
