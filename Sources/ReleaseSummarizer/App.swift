import ArgumentParser
import OpenAI
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

        let releaseNote = """
        Added: Observation support (#2593), which both streamlines and soft-deprecates many concepts in the Composable Architecture. See the 1.7 migration guide for more information on how to apply these updates to your applications.
        Infrastructure: Add CI for Swift 5.7.1 (#2701).
        Infrastructure: Add docs for testing StackAction's case path subscript (thanks @lukeredpath, #2704).
        Infrastructure: Fixed examples CI (#2715).
        Infrastructure: Fixed TestStore.assert docs (#2720).
        Infrastructure: Use XCTExpectFailure from XCTestDynamicOverlay (#2721).
        Infrastructure: Documentation typo fix (thanks @JonCox, #2723).
        Infrastructure: Fixed concurrency docs (thanks @hmhv, #2726).
        Infrastructure: Fixed composing features tutorial (thanks @bricklife, #2698; thanks @Kyome22, #2727).
        Infrastructure: Fixed 1.7 migration guide (thanks @Ryu0118, #2731).
        """

        let prompt = """
以下はソフトウェアのリリース内容です。
リリース内容をを要約してください。

制約事項:
- 日本語で出力する
- 箇条書きで出力する
- 1項目200文字以内で要約する
- ソフトウェアへの変更内容のみに限定する
- Markdown 形式で出力する
- 丁寧語で出力する

各項目は以下のフォーマットで出力してください。

### 項目名
- 説明
"""


        let query = ChatQuery(model: .gpt3_5Turbo_1106, messages: [
            Chat(role: .system, content: prompt),
            Chat(role: .user, content: releaseNote),
        ])
        let result = try await OpenAI(apiToken: apiToken).chats(query: query)

        for choice in result.choices {
            print(choice.message.content!)
        }
    }
}

extension Logger {
    fileprivate static let app = Logger(label: "io.github.ios-osushi.releasesummarizer")
}
