//
//  ReleaseSubscriptionsCoreTests.swift
//  ReleaseSubscriptionsCoreTests
//
//  Created by treastrain on 2022/03/29.
//

import XCTest
@testable import ReleaseSubscriptionsCore

final class ReleaseSubscriptionsCoreTests: XCTestCase {
    func testYamlParsing() throws {
        _ = try Parser.parse()
    }
    
    func testREADMELoading() throws {
        _ = try FileHelper.readFromREADME()
    }
    
    func testPastOutputsLoading() throws {
        let repositories = try Parser.parse()
        _ = try FileHelper.load(repositories: repositories)
    }
    
    func testYamlSortOrderChecking() throws {
        let repositories = try Parser.parse()
        let sortedRepositories = repositories
            .sorted { $0.repository.lowercased() < $1.repository.lowercased() }
            .sorted { $0.owner.lowercased() < $1.owner.lowercased() }
            .sorted { $0.slackWebhookDestination < $1.slackWebhookDestination }
        XCTAssertEqual(repositories, sortedRepositories, """
        The description in the YAML file does not follow the sort order rules. Please describe them in the following order.
        --------------------------------------------------
        repositories:
        \(
        sortedRepositories.map {
        """
          - kind: \($0.slackWebhookDestination.rawValue)
            case: \($0.rawValue)
            name: \($0.name)
            owner: \($0.owner)
            repo: \($0.repository)
          
        """
        }
        .joined(separator: "\n")
        )
        --------------------------------------------------
        """)
    }
}
