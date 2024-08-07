//
//  App.swift
//  ReleaseSubscriptions
//
//  Created by treastrain on 2022/03/29.
//

import ArgumentParser
import Foundation
import Logging
import ReleaseSubscriptionsCore

@main
struct App: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "GitHub Access Token to fetch repositories.")
    var accessToken: String?

    @Option(name: .shortAndLong, help: "Slack Webhook URL (primary) to be notified of updates.", transform: URL.init(string:))
    var primarySlackURL: URL?
    
    @Option(name: .shortAndLong, help: "Slack Webhook URL (secondary) to be notified of updates.", transform: URL.init(string:))
    var secondarySlackURL: URL?
    
    func run() async throws {
        defer {
            Logger.app.info("🎉 \(#function) finished")
        }
        Logger.app.info("ℹ️ \(#function) started")
        do {
            if accessToken == nil {
                Logger.app.info("🔔 accessToken is nil")
            }
            if primarySlackURL == nil {
                Logger.app.info("🔔 primarySlackURL is nil")
            }
            if secondarySlackURL == nil {
                Logger.app.info("🔔 secondarySlackURL is nil")
            }
            let repositories = try Parser.parse()
            let oldContents = try FileHelper.load(repositories: repositories)
            let newContents = try await Fetcher.fetch(repositories: repositories, accessToken: accessToken)
            let combinedContents = oldContents.merging(newContents) { ($0 + $1).identified().sorted() }
            let updatedContents = DifferenceComparator.insertions(repositories: repositories, old: oldContents, new: combinedContents)
            try await SlackNotifier.notify(to: slackURLs(), updates: updatedContents)
            try FileHelper.save(contents: combinedContents)
            try FileHelper.writeToREADME(repositories: repositories)
        } catch {
            Logger.app.error("❌ \(error)")
            throw error
        }
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

extension Logger {
    fileprivate static let app = Logger(label: "io.github.ios-osushi.releasesubscriptions")
}
