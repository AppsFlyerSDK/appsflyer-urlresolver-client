//
//  Helpers.swift
//  AppsFlyerURLResolver
//
//  Created by Amit Kremer on 14/06/2022.
//

import Foundation

struct Helpers {
    static func htmlFileToString(for filePath: String) -> String? {
        let htmlString = try? String(contentsOfFile: filePath, encoding: .utf8)
        return htmlString
    }
}
