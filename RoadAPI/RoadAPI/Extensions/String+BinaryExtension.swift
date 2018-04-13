//
//  String+BinaryExtension.swift
//  RoadAPI
//
//  Created by Denys on 1/10/18.
//  Copyright © 2018 Denys Zhukov. All rights reserved.
//

import Foundation

extension String {
    
    var isBinary: Bool {
        let characterSet = CharacterSet(charactersIn: "01").inverted
        let componetes = self.components(separatedBy: characterSet)
        return componetes.count == 1
    }
    
    func reversBinaryString() -> String? {
        guard self.isBinary else { return nil }
        var reversed = ""
        for character in self {
            let reversedChar = character == "0" ? "1" : "0"
            reversed.append(reversedChar)
        }
        return reversed
    }
    
    func intFromBinaryString() -> Int? {
        let result = Int(self, radix: 2)
        return result
    }
    
    func removeLeading(with character: Character) -> String {
        var result = self
        for char in result {
            guard char == character else { break }
            result.removeFirst()
        }
        return result
    }
    
}
