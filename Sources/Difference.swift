//
//  Difference.swift
//  Difference
//
//  Created by Krzysztof Zablocki on 18.10.2017
//  Copyright © 2017 Krzysztof Zablocki. All rights reserved.
//

import Foundation

fileprivate extension String {
    init<T>(dumping object: T) {
        self.init()
        dump(object, to: &self)
    }
}

/// Compares 2 objects and iterates over their differences
///
/// - Parameters:
///   - lhs: expected object
///   - rhs: received object
///   - closure: iteration closure
fileprivate func diff<T>(_ expected: T, _ received: T, level: Int = 0, closure: (_ description: String) -> Void) {
    let lhsMirror = Mirror(reflecting: expected)
    let rhsMirror = Mirror(reflecting: received)

    let zipped = zip(lhsMirror.children, rhsMirror.children)
    zipped.forEach { (lhs, rhs) in
        let leftDump = String(dumping: lhs.value)
        if leftDump != String(dumping: rhs.value) {
            if let notPrimitive = Mirror(reflecting: lhs.value).displayStyle, notPrimitive != .tuple {
                var results = [String]()
                diff(lhs.value, rhs.value, level: level + 1) { diff in
                    results.append(diff)
                }
                if !results.isEmpty {
                    closure("child \(lhs.label ?? ""):\n\((0..<level).reduce("") { acc, _ in acc + "\t" })" + results.joined())
                }
            } else {
                closure("\(lhs.label ?? "") received: \"\(rhs.value)\" expected: \"\(lhs.value)\"\n")
            }
        }
    }
}


/// Builds list of differences between 2 objects
///
/// - Parameters:
///   - expected: Expected value
///   - received: Received value
/// - Returns: List of differences
public func diff<T>(_ expected: T, _ received: T) -> [String] {
    var all = [String]()
    diff(expected, received) { all.append($0) }
    return all
}

/// Prints list of differences between 2 objects
///
/// - Parameters:
///   - expected: Expected value
///   - received: Received value
public func dumpDiff<T: Equatable>(_ expected: T, _ received: T) {
    // skip equal
    guard expected != received else {
        return
    }

    diff(expected, received).forEach { print($0) }
}

/// Prints list of differences between 2 objects
///
/// - Parameters:
///   - expected: Expected value
///   - received: Received value
public func dumpDiff<T>(_ expected: T, _ received: T) {
    diff(expected, received).forEach { print($0) }
}
