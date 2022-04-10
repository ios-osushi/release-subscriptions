//
//  SlackWebhookDestination.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/09.
//

import Foundation

public enum SlackWebhookDestination: String, Codable, CaseIterable {
    case primary
    case secondary
    
    var number: Int {
        switch self {
        case .primary:
            return 1
        case .secondary:
            return 2
        }
    }
}

extension SlackWebhookDestination: Comparable {
    public static func < (lhs: SlackWebhookDestination, rhs: SlackWebhookDestination) -> Bool {
        lhs.number < rhs.number
    }
}
