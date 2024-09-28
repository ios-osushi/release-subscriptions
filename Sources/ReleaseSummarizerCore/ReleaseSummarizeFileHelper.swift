//
//  File.swift
//  ReleaseSubscriptions
//
//  Created by 伊藤凌也 on 2024/09/28.
//

import Foundation
import Logging

public struct ReleaseSummarizeFileHelper {
    public static func writeToFile(fileContent: String) throws {
        defer {
            Logger.helper.info("🎉 \(#function) finished")
        }
        Logger.helper.info("ℹ️ \(#function) started")
        try fileContent.write(toFile: "./output.md", atomically: true, encoding: .utf8)
    }
}

extension Logger {
    fileprivate static let helper = Logger(label: "io.github.ios-osushi.releasesummarizer.filehelper")
}
