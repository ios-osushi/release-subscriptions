import ArgumentParser
import Foundation
import ReleaseSummarizerCore
import ReleaseSubscriptionsCore
import Logging

@main
struct App: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "OpenAI APIToken for generating summary of change log")
    var apiToken: String?

    func run() async throws {
        guard let apiToken = apiToken else {
            Logger.app.error("An argument apiToken is needed. Please pass OpenAI apiKey.")
            return
        }

        let repositories = try Parser.parse()
        let components = DateComponents(year: 2024, month: 9, day: 21)
        let date = Calendar.current.date(from: components)
        let prompt = """
次の文章はとあるライブラリのリリース情報です。
この内容を短くわかりやすい表現で要約してください。
要約の内容は
・改善点
・修正点
・その他
に分けて日本語で行ってください。
"""

        let releases = try await ReleaseCollector.collect(for: repositories, from: date!)
        let generatedContent = try await ReleaseSummarizeGenerator.generate(apiToken: apiToken, prompt: prompt, releases: releases)

        print(generatedContent)
    }
}

extension Logger {
    fileprivate static let app = Logger(label: "io.github.ios-osushi.releasesummarizer")
}
