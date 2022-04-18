//
//  Parser.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/02.
//

import Foundation
import Yaml

public struct Parser {
    enum Error: Swift.Error {
        case invalidYamlFormat
        case invalidREADMEFormat
        case unknownCase
    }
    
    public static func parse() throws -> [GitHubRepository] {
        let url = URL.topLevelDirectory.appendingPathComponent("ReleaseSubscriptions.yml")
        let string = try String(contentsOf: url)
        let yaml = try Yaml.load(string)
        guard let repositoriesYaml = yaml["repositories"].array else {
            throw Error.invalidYamlFormat
        }
        return try repositoriesYaml.map { repositoryYaml -> GitHubRepository in
            guard let kind = repositoryYaml["kind"].string,
                  let destination = SlackWebhookDestination(rawValue: kind),
                  let `case` = repositoryYaml["case"].string,
                  let name = repositoryYaml["name"].string,
                  let owner = repositoryYaml["owner"].string,
                  let repository = repositoryYaml["repo"].string else {
                throw Error.invalidYamlFormat
            }
            switch `case` {
            case "releases":
                return .releases(destination, .init(name: name, owner: owner, repository: repository))
            case "tags":
                return .tags(destination, .init(name: name, owner: owner, repository: repository))
            default:
                throw Error.unknownCase
            }
        }
    }
    
    public static func writeToREADME(repositories: [GitHubRepository]) throws {
        let lowerBoundKeyword = "<!-- BEGIN LIST OF REPOSITORIES (AUTOMATICALLY OUTPUT) -->"
        let upperBoundKeyword = "<!-- END LIST OF REPOSITORIES (AUTOMATICALLY OUTPUT) -->"
        let url = URL.topLevelDirectory.appendingPathComponent("README.md")
        var string = try String(contentsOf: url)
        guard let lowerBound = string.range(of: lowerBoundKeyword)?.lowerBound,
              let upperBound = string.range(of: upperBoundKeyword)?.upperBound else {
            throw Error.invalidREADMEFormat
        }
        let outputListOfRepositoriesString = """
        \(lowerBoundKeyword)
        |名前|リポジトリ|スター数|ウォッチ数|
        |:--|:--|:--|:--|
        
        """
        + repositories.map {
            let repository = "\($0.owner)/\($0.repository)"
            return "|\($0.name)|[\(repository)](https://github.com/\(repository))|[![GitHub Repo stars](https://img.shields.io/github/stars/\(repository)?style=social)](https://github.com/\(repository)/stargazers)|[![GitHub watchers](https://img.shields.io/github/watchers/\(repository)?style=social)](https://github.com/\(repository)/watchers)|\n"
        }.joined()
        + upperBoundKeyword
        string.replaceSubrange(lowerBound..<upperBound, with: outputListOfRepositoriesString)
        try string.write(to: url, atomically: true, encoding: .utf8)
    }
}
