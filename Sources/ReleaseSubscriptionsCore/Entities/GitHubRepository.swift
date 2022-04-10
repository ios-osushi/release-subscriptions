//
//  GitHubRepository.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/02.
//

import Foundation

protocol GitHubRepositoryProtocol {
    var name: String { get }
    var owner: String { get }
    var repository: String { get }
    var url: URL { get }
    var outputJSONFileName: String { get }
}

extension GitHubRepositoryProtocol {
    var url: URL {
        URL(string: "https://github.com/\(owner)/\(repository)")!
    }
    var outputJSONFileName: String {
        name + ".json"
    }
}

protocol GitHubAPIURLConvertible {
    var apiURL: URL { get }
}

public enum GitHubRepository: Codable, Hashable {
    case tags(SlackWebhookDestination, Tags)
    case releases(SlackWebhookDestination, Releases)
    
    public struct Tags: GitHubRepositoryProtocol, GitHubAPIURLConvertible, Codable, Hashable {
        let name: String
        let owner: String
        let repository: String
        
        var apiURL: URL {
            .init(string: "https://api.github.com/repos/\(owner)/\(repository)/tags")!
        }
    }
    
    public struct Releases: GitHubRepositoryProtocol, GitHubAPIURLConvertible, Codable, Hashable {
        let name: String
        let owner: String
        let repository: String
        
        var apiURL: URL {
            .init(string: "https://api.github.com/repos/\(owner)/\(repository)/releases")!
        }
    }
    
    public var rawValue: String {
        switch self {
        case .tags(_, _):
            return "tags"
        case .releases(_, _):
            return "releases"
        }
    }
    
    var slackWebhookDestination: SlackWebhookDestination {
        switch self {
        case .tags(let slackWebhookDestination, _), .releases(let slackWebhookDestination, _):
            return slackWebhookDestination
        }
    }
}

extension GitHubRepository: GitHubRepositoryProtocol {
    var name: String {
        switch self {
        case .tags(_, let tags):
            return tags.name
        case .releases(_, let releases):
            return releases.name
        }
    }
    
    var owner: String {
        switch self {
        case .tags(_, let tags):
            return tags.owner
        case .releases(_, let releases):
            return releases.owner
        }
    }
    
    var repository: String {
        switch self {
        case .tags(_, let tags):
            return tags.repository
        case .releases(_, let releases):
            return releases.repository
        }
    }
}

extension GitHubRepository: GitHubAPIURLConvertible {
    var apiURL: URL {
        switch self {
        case .tags(_, let tags):
            return tags.apiURL
        case .releases(_, let releases):
            return releases.apiURL
        }
    }
}
