//
//  QuickAssertions.swift
//  Difference
//
//  Created by Krzysztof Zablocki on 18/10/2017.
//  Copyright © 2017 Difference. All rights reserved.
//

import Foundation
import Quick
import Nimble

public func equalDiff<T: Equatable>(_ otherObject: T?) -> Predicate<T> {
    return Predicate.define { actualExpression in
        guard let otherObject = otherObject else {
            return PredicateResult(status: .fail, message: ExpectationMessage.fail("").appendedBeNilHint())
        }

        let object = try actualExpression.evaluate()

        return PredicateResult(bool: object != otherObject, message: ExpectationMessage.fail("Found difference for " + diff(object, otherObject).joined(separator: ", ")))
    }
}
