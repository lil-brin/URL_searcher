//
//  StringExtensions.swift
//  developex_test
//
//  Created by Brin on 6/17/19.
//  Copyright © 2019 Brin. All rights reserved.
//

import Foundation

extension String {
    func extractURLs() -> [URL] {
        var urls : [URL] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            detector.enumerateMatches(in: self, options: [], range: NSMakeRange(0, self.count)) {
                (result, _, _) in
                if let match = result, let url = match.url {
                    if (url.absoluteString.hasPrefix("http")) {
                        urls.append(url)
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return urls
    }
}


extension Int {
    mutating func increase(by value: Int = 1) {
        self += value
    }
    
    mutating func decrease(by value: Int = 1) {
        self -= value
    }
}
