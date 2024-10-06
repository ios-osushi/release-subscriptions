//
//  Release.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/03/29.
//

import Foundation

public struct Release: Identifiable {
    public let id: String
    public let owner: String
    public let repository: String
    public let version: String
    public let title: String
    @JSONNullable public var body: String?
    public let url: URL
    @JSONNullable var createdAt: Date?
    @JSONNullable public var publishedAt: Date?
    let fetchedFromAPIAt: Date
}

extension Release: Equatable {
    public static func == (lhs: Release, rhs: Release) -> Bool {
        lhs.id == rhs.id
        && lhs.owner == rhs.owner
        && lhs.repository == rhs.repository
        && lhs.version == rhs.version
        && lhs.title == rhs.title
        && lhs.body == rhs.body
        && lhs.url == rhs.url
        && lhs.createdAt == rhs.createdAt
        && lhs.publishedAt == rhs.publishedAt
    }
}

extension Release: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(owner)
        hasher.combine(repository)
        hasher.combine(version)
        hasher.combine(title)
        hasher.combine(body)
        hasher.combine(url)
        hasher.combine(createdAt)
        hasher.combine(publishedAt)
    }
}

extension Release: Comparable {
    public static func < (lhs: Release, rhs: Release) -> Bool {
        lhs.id < rhs.id
    }
}

extension Release: Encodable {}

extension Release: Decodable {
    enum DecodingKeys: CodingKey {
        case node_id
        case zipball_url
        case tag_name
        case name
        case body
        case html_url
        case created_at
        case published_at
    }
    
    public init(from decoder: Decoder) throws {
        var decodedId: String
        var decodedOwner: String
        var decodedRepository: String
        var decodedVersion: String
        var decodedTitle: String
        var decodedBody: String?
        var decodedURL: URL
        var decodedCreatedAt: Date?
        var decodedPublishedAt: Date?
        var decodedFetchedFromAPIAt: Date
        
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            decodedId = try container.decode(String.self, forKey: .id)
            decodedOwner = try container.decode(String.self, forKey: .owner)
            decodedRepository = try container.decode(String.self, forKey: .repository)
            decodedVersion = try container.decode(String.self, forKey: .version)
            decodedTitle = try container.decode(String.self, forKey: .title)
            decodedBody = try container.decode(String?.self, forKey: .body)
            decodedURL = try container.decode(URL.self, forKey: .url)
            decodedCreatedAt = try container.decode(Date?.self, forKey: .createdAt)
            decodedPublishedAt = try container.decode(Date?.self, forKey: .publishedAt)
            decodedFetchedFromAPIAt = try container.decode(Date.self, forKey: .fetchedFromAPIAt)
        } catch {
            let container = try decoder.container(keyedBy: DecodingKeys.self)
            decodedId = try container.decode(String.self, forKey: .node_id)
            let zipBallURLPathComponentsString = try container.decode(String.self, forKey: .zipball_url)
                .replacingOccurrences(of: "https://api.github.com/repos/", with: "")
            let zipBallURLPathComponents = zipBallURLPathComponentsString.split(separator: "/")
            decodedOwner = String(zipBallURLPathComponents[0])
            decodedRepository = String(zipBallURLPathComponents[1])
            if zipBallURLPathComponentsString.contains("refs/tags") {
                decodedVersion = try container.decode(String.self, forKey: .name)
                decodedTitle = try container.decode(String.self, forKey: .name)
                decodedBody = nil
                decodedURL = URL(string: "https://github.com/\(decodedOwner)/\(decodedRepository)/releases/tag/\(decodedVersion)")!
                decodedCreatedAt = nil
                decodedPublishedAt = nil
            } else {
                decodedVersion = try container.decode(String.self, forKey: .tag_name)
                decodedTitle = (try? container.decode(String.self, forKey: .name)) ?? decodedVersion
                decodedBody = try? container.decode(String.self, forKey: .body)
                decodedURL = try container.decode(URL.self, forKey: .html_url)
                decodedCreatedAt = try container.decode(Date.self, forKey: .created_at)
                decodedPublishedAt = try container.decode(Date.self, forKey: .published_at)
            }
            decodedFetchedFromAPIAt = Date()
        }
        
        id = decodedId
        owner = decodedOwner
        repository = decodedRepository
        version = decodedVersion
        title = decodedTitle
        body = decodedBody
        url = decodedURL
        createdAt = decodedCreatedAt
        publishedAt = decodedPublishedAt
        fetchedFromAPIAt = decodedFetchedFromAPIAt
    }
}
