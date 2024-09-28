import ArgumentParser
import Foundation
import ReleaseSummarizerCore
import ReleaseSubscriptionsCore
import Logging

@main
struct App: AsyncParsableCommand {

    static var configuration: CommandConfiguration {
        .init(
            commandName: "releaseSummarizer"
        )
    }

    @Option(
        name: .shortAndLong,
        help: "Gemini APIKey for generating summary of change log"
    )
    var apiToken: String?

    @Option(
        name: .long,
        help: "Generate article target date range from. yyyy/MM/dd date format string",
        transform: ISO8601DateFormatter().date(from:)
    )
    var from: Date?

    @Option(
        name: .long,
        help: "Generate article target date range to. yyyy/MM/dd date format string. default: today",
        transform: ISO8601DateFormatter().date(from:)
    )
    var to: Date?

    func run() async throws {
        guard let apiToken = apiToken else {
            Logger.app.error("An argument apiToken is needed. Please pass Gemini apiKey.")
            return
        }

        guard let from else {
            Logger.app.error("An argument from is needed or invalid. Please pass date range from.")
            return
        }

        let repositories = try ReleaseSubscriptionsParser.parse()
        let releases = try await ReleaseCollector.collect(
            for: repositories,
            from: from,
            to: to ?? Date()
        )
        let generatedContent = try await ReleaseSummarizeGenerator.generate(apiToken: apiToken, prompt: prompt, releases: releases)

        try ReleaseSummarizeFileHelper.writeToFile(fileContent: generatedContent)
    }
}

extension App {
    var prompt: String {
"""
次の文章はとあるライブラリのリリース情報です。
この内容を短くわかりやすい表現で要約してください。
要約の内容は
・改善点
・修正点
・その他
に分けて日本語で行ってください。
内容は箇条書きの Markdown 形式で出力してください。
また、各箇条書きの項目は50文字以内で収めて、ですます調で出力してください。

出力例:

##### 改善点

内容

##### 修正点

内容

##### その他

内容
"""
    }
}

extension Logger {
    fileprivate static let app = Logger(label: "io.github.ios-osushi.releasesummarizer")
}
