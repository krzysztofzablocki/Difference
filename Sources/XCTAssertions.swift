//
//  XCTAssertions.swift
//  Difference
//
//  Created by Krzysztof Zablocki on 18/10/2017.
//  Copyright © 2017 Difference. All rights reserved.
//

import Foundation
import XCTest
import Difference

/// Asserts objects are equal and prints difference if they aren't
///
/// - Parameters:
///   - expected: Expected object
///   - received: Received object
///   - file: File the assertion should show at
///   - line: Line the assertion should show at
public func AssertEqual<T: Equatable>(_ expected: T, _ received: T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(expected == received, "Found difference for " + diff(expected, received).joined(separator: ", "), file: file, line: line)
}
