//
//  SlackNotifier.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/04.
//

@preconcurrency import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging
import Markdown

public struct SlackNotifier {
    enum Error: Swift.Error {
        case invalidSlackURL
        case invalidHTTPResponseStatus(URLResponse, String?, GitHubRepository, Release)
    }
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        formatter.locale = .init(identifier: "ja_JP")
        formatter.timeZone = .init(identifier: "Asia/Tokyo")
        return formatter
    }()
    
    public static func notify(to slackURLs: [SlackWebhookDestination : URL], updates: [GitHubRepository : [Release]]) async throws {
        defer {
            Logger.shared.info("🎉 \(#function) finished")
        }
        Logger.shared.info("ℹ️ \(#function) started")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (repository, releases) in updates {
                for release in releases {
                    group.addTask {
                        Logger.shared.info("ℹ️ Notifing to Slack (\(repository.slackWebhookDestination)) about \(repository.name) releases")
                        let publishedAt = release.publishedAt == nil ? nil : formatter.string(from: release.publishedAt!)
                        let body = Document(parsing: release.body ?? "")
                            .children
                            .compactMap { ($0 as? Paragraph)?.plainText }
                            .joined(separator: " ")
                        let message = message(name: repository.name, owner: repository.owner, repo: repository.repository, repoURL: repository.url, title: release.title, version: release.version, releaseURL: release.url, publishedAt: publishedAt, body: body)
                        guard let slackURL = slackURLs[repository.slackWebhookDestination] else {
                            throw Error.invalidSlackURL
                        }
                        var request = URLRequest(url: slackURL)
                        request.httpMethod = "POST"
                        request.addValue("application/json", forHTTPHeaderField: "Content-type")
                        request.httpBody = message.data(using: .utf8)
                        let (data, response) = try await URLSession.shared.data(for: request)
                        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                            throw Error.invalidHTTPResponseStatus(response, String(data: data, encoding: .utf8), repository, release)
                        }
                        Logger.shared.info("✅ Successfully notified Slack (\(repository.slackWebhookDestination)) of the \(repository.name) release!")
                    }
                }
            }
            try await group.waitForAll()
        }
    }
    
    static private func message(name: String, owner: String, repo: String, repoURL: URL, title: String, version: String, releaseURL: URL, publishedAt: String?, body: String) -> String {
    """
    {
        "text": "\(name) \(version) がリリースされました。",
        "blocks": [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": "\(title) - \(name)",
                    "emoji": true
                }
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": "*リポジトリ:*\n<\(repoURL)|\(owner)/\(repo)>"
                    },
                    {
                        "type": "mrkdwn",
                        "text": "*バージョン\(publishedAt != nil ? "・公開日時" : ""):*\n<\(releaseURL)|\(version)>\(publishedAt != nil ? "\n\(publishedAt!)" : "")"
                    }
                ]
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "\(body.isEmpty ? " " : String(body.prefix(1500)))"
                }
            }
        ]
    }
    """
    }
}
