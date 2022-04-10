//
//  DifferenceComparator.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/04.
//

import Foundation

public struct DifferenceComparator {
    public static func insertions(repositories: [GitHubRepository], old: [GitHubRepository : [Release]], new: [GitHubRepository : [Release]]) -> [GitHubRepository : [Release]] {
        var insertions: [GitHubRepository : [Release]] = [:]
        for repository in repositories {
            guard let oldReleases = old[repository] else {
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
        }
        return insertions
    }
}
