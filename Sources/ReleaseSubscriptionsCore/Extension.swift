//
//  Extension.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/07.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

extension Logger {
    static let shared = Logger(label: "io.github.ios-osushi.releasesubscriptionscore")
}

public extension URL {
    static let topLevelDirectory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

public extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        let request = URLRequest(url: url)
        return try await data(for: request)
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (data!, response!))
                }
            }
            dataTask.resume()
        }
    }
}

public extension Array where Element: Identifiable {
    func identified() -> Self {
        var ids: Set<Element.ID> = []
        return filter { element in
            let (inserted, _) = ids.insert(element.id)
            return inserted
        }
    }
}
