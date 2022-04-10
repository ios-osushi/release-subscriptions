//
//  App.swift
//  ReleaseSubscriptions
//
//  Created by treastrain on 2022/03/29.
//

import ArgumentParser
import Foundation
import ReleaseSubscriptionsCore

@main
struct App: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "Slack Webhook URL (primary) to be notified of updates.", transform: URL.init(string:))
    var primarySlackURL: URL?
    
    @Option(name: .shortAndLong, help: "Slack Webhook URL (secondary) to be notified of updates.", transform: URL.init(string:))
    var secondarySlackURL: URL?
    
    func run() async throws {
        let repositories = try Parser.parse()
        let oldContents = try FileHelper.load(repositories: repositories)
        let newContents = try await Fetcher.fetch(repositories: repositories)
        let updatedContents = DifferenceComparator.insertions(repositories: repositories, old: oldContents, new: newContents)
        try await SlackNotifier.notify(to: slackURLs(), updates: updatedContents)
        let mergedContents = newContents.merging(updatedContents.reduce(into: [:]) { $0[$1.key] = $1.value + (oldContents[$1.key] ?? []) }) { $1 }
        try FileHelper.save(contents: mergedContents)
    }
    
    private func slackURLs() -> [SlackWebhookDestination : URL] {
        SlackWebhookDestination.allCases.reduce(into: [:]) {
            let url: URL?
            switch $1 {
            case .primary:
                url = primarySlackURL
            case .secondary:
                url = secondarySlackURL
            }
            $0[$1] = url
        }
    }
}
