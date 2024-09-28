//
//  ReleaseCollector.swift
//  ReleaseSubscriptions
//
//  Created by 伊藤凌也 on 2024/09/28.
//

import Foundation
import ReleaseSubscriptionsCore

public struct ReleaseCollector {
    public static func collect(for repositories: [GitHubRepository], from: Date, to: Date = Date()) async throws -> [(GitHubRepository, Release)] {
        try OutputFileHelper.load(repositories: repositories)
            .flatMap { (repository, releases) in
                releases.map { (repository, $0) }
            }
            .filter { (repository, release) in
                guard let publishedAt = release.publishedAt else {
                    return false
                }

                return (from...to).contains(publishedAt)
            }
    }
}
