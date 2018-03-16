//
//  EncodableExtension.swift
//  HOOOP
//
//  Created by James Woodrow on 16/03/2018.
//  Copyright © 2018 Hooop. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "HOOOP", code: 42, userInfo: nil)
        }
        return dictionary
    }
}

