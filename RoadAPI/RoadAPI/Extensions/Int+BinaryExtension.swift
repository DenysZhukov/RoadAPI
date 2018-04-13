//
//  Int+BinaryExtension.swift
//  RoadAPI
//
//  Created by Denys on 1/10/18.
//  Copyright © 2018 Denys Zhukov. All rights reserved.
//

import Foundation

extension Int {
    
    var isNegative: Bool {
        return self.signum() < 0
    }
    
    func binaryString() -> String? {
        let bitInByte = 8
        let binaryStr = String(abs(self), radix: 2, uppercase: false)
        let byteNumber = Int(ceilf(Float(binaryStr.count) / Float(bitInByte)))
        let zeroString = String(repeating: "0", count: byteNumber * bitInByte - binaryStr.count)
        let resultString = zeroString + binaryStr
        if self.isNegative {
            guard let reversed = resultString.reversBinaryString(),
                var decimal = reversed.intFromBinaryString() else { return nil }
            decimal += 1
            return String(decimal, radix: 2, uppercase: false)
        } else {
            return binaryStr
        }
    }
    
}
