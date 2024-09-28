//
//  Generator.swift
//  ReleaseSubscriptions
//
//  Created by 伊藤凌也 on 2024/09/28.
//

import GoogleGenerativeAI
import Logging
import ReleaseSubscriptionsCore

public struct ReleaseSummarizeGenerator {

    /// リリース情報に限った記事の内容を生成する
    ///
    /// フォーマット
    ///
    ///
    /// ## OSS のリリース情報
    ///
    /// iOS アプリ開発でよく使われている OSS のリリース情報です。
    ///
    /// ### Apple
    /// #### {バージョン} - ライブラリ名
    ///
    /// [{release url}]({release url})
    ///
    /// ##### 改善点
    ///
    /// 内容
    ///
    /// ##### 修正点
    ///
    /// 内容
    ///
    /// ##### その他
    ///
    /// 内容
    ///
    /// ### サードパーティ
    ///
    /// ...
    ///
    public static func generate(
        apiToken: String,
        prompt: String,
        releases: [(GitHubRepository, Release)]
    ) async throws -> String {
        let grouped: [SlackWebhookDestination: [Release]] = releases.reduce(into: [:]) { partialResult, release in
            let (repository, release) = release

            let destination = switch repository {
            case let .releases(destination, _):
                destination

            case let .tags(destination, _):
                destination
            }

            if partialResult[destination] != nil {
                partialResult[destination]?.append(release)
            } else {
                partialResult[destination] = [release]
            }
        }

        var builder = Builder()
        for (key, releases) in grouped {
            builder.addSection(destination: key)

            for release in releases {
                Logger.generator.info("Generating release content for \(release.owner)/\(release.repository) ...")

                let model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: apiToken)
                let result = try await model.generateContent(prompt, release.body ?? "")

                if let content = result.text {
                    builder.addRelease(release: release, generatedContent: content)
                }

                try await Task.sleep(nanoseconds: 5000_000_000)
            }
        }

        return builder.result
    }

    struct Builder {
        var result = """
## OSS のリリース情報

iOS アプリ開発でよく使われている OSS のリリース情報です。

"""

        mutating func addSection(destination: SlackWebhookDestination) {
            let title = switch destination {
            case .primary:
                "Apple"

            case .secondary:
                "サードパーティ"
            }

            result.append("### \(title)\n")
        }

        /// #### {バージョン} - ライブラリ名
        mutating func addRelease(release: Release, generatedContent: String) {
            let content = """
#### \(release.version) - \(release.owner)/\(release.repository)

[\(release.url)](\(release.url)

\(generatedContent)

"""
            result.append(content)
        }
    }
}

extension Logger {
    fileprivate static let generator = Logger(label: "io.github.ios-osushi.releasesummarizer.generator")
}
