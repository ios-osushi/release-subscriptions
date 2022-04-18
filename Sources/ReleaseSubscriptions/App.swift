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
        let combinedContents = oldContents.merging(newContents) { old, new in
            Set(old + new).sorted()
        }

        let updatedContents = DifferenceComparator.insertions(repositories: repositories, old: oldContents, new: combinedContents)
        try await SlackNotifier.notify(to: slackURLs(), updates: updatedContents)
        try FileHelper.save(contents: combinedContents)
        try Parser.writeToREADME(repositories: repositories)
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
