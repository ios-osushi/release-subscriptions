//
//  JSONNullable.swift
//  ReleaseSubscriptionsCore
//
//  Created by treastrain on 2022/04/03.
//

import Foundation

/// [iOSDC Japan 2021 | CodableでJSONのNullを出力するためのTips by hirotakan](https://fortee.jp/iosdc-japan-2021/proposal/a79f93a5-1f1b-4017-86ad-64ed6f27d2b8) をもとに作成
@propertyWrapper
struct JSONNullable<T: Codable>: Codable {
    var wrappedValue: T?
    
    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        wrappedValue = try Optional<T>(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ type: JSONNullable<T>.Type, forKey key: Key) throws -> JSONNullable<T> {
        try type.init(from: superDecoder(forKey: key))
    }
}
