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
        case unknownCase
    }
    
    public static func parse() throws -> [GitHubRepository] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ReleaseSubscriptions.yml")
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
}
