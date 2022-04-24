//
//  Parser.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/02.
//

import Foundation
import Logging
import Yaml

public struct Parser {
    enum Error: Swift.Error {
        case invalidYamlFormat
        case unknownCase
    }
    
    public static func parse() throws -> [GitHubRepository] {
        Logger.shared.info("ℹ️ \(#function) started.")
        let url = URL.topLevelDirectory.appendingPathComponent("ReleaseSubscriptions.yml")
        let string = try String(contentsOf: url)
        let yaml = try Yaml.load(string)
        guard let repositoriesYaml = yaml["repositories"].array else {
            throw Error.invalidYamlFormat
        }
        return try repositoriesYaml.map { repositoryYaml -> GitHubRepository in
            Logger.shared.info("ℹ️ Creating object: \(repositoryYaml["name"].string ?? "nil") (\(repositoryYaml["case"].string ?? "nil"))")
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
                Logger.shared.info("✅ The correct YAML format: \(name) (\(`case`))")
                return .releases(destination, .init(name: name, owner: owner, repository: repository))
            case "tags":
                Logger.shared.info("✅ The correct YAML format: \(name) (\(`case`))")
                return .tags(destination, .init(name: name, owner: owner, repository: repository))
            default:
                throw Error.unknownCase
            }
        }
    }
}
