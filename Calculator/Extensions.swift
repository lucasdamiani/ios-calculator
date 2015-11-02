//
//  Extensions.swift
//  Calculator
//
//  Created by Lucas Damiani on 13/09/15.
//  Copyright © 2015 Lucas Damiani. All rights reserved.
//

import Foundation

extension NSNumber {
    var isInteger: Bool {
        var rounded = decimalValue
        NSDecimalRound(&rounded, &rounded, 0, NSRoundingMode.RoundDown)
        return NSDecimalNumber(decimal: rounded) == self
    }
    
    var isFraction: Bool { return !isInteger }
}