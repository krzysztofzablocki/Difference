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

    guard lhsMirror.children.count != 0, rhsMirror.children.count != 0 else {
        if String(dumping: received) != String(dumping: expected) {
            closure("received: \"\(received)\" expected: \"\(expected)\"\n")
        }
        return
    }

    let hasDiffNumOfChildren = lhsMirror.children.count != rhsMirror.children.count
    switch (lhsMirror.displayStyle, rhsMirror.displayStyle) {
    case (.collection?, .collection?) where hasDiffNumOfChildren,
         (.dictionary?, .dictionary?) where hasDiffNumOfChildren,
         (.set?, .set?) where hasDiffNumOfChildren:
            closure("""
                different count:
                \(indentation(level: level))received: \"\(received)\" (\(rhsMirror.children.count))
                \(indentation(level: level))expected: \"\(expected)\" (\(lhsMirror.children.count))\n
                """)
        return
    case (.dictionary?, .dictionary?):
        if let expectedDict = expected as? Dictionary<AnyHashable, Any>,
            let receivedDict = received as? Dictionary<AnyHashable, Any> {
            expectedDict.keys.forEach { key in
                var results = [String]()
                diff(expectedDict[key], receivedDict[key], level: level + 1) { diff in
                    results.append(diff)
                }
                if !results.isEmpty {
                    closure("child key \(key.description):\n\(indentation(level: max(level, 1)))" + results.joined(separator: "\n\(indentation(level: max(level, 1)))"))
                }
            }
            return
        }

    case (.set?, .set?):
        if let expectedSet = expected as? Set<AnyHashable>,
            let receivedSet = received as? Set<AnyHashable> {
            let uniqueExpected = expectedSet.subtracting(receivedSet)
            let uniqueReceived = receivedSet.subtracting(expectedSet)

            var results = [String]()
            uniqueExpected.forEach { unique in
                results.append("SetElement missing: \(unique.description)\n")
            }
//            zip(uniqueExpected, uniqueReceived).forEach { lhs, rhs in
//                diff(lhs, rhs, level: level + 1) { diff in
//                    results.append("\(indentation(level: max(level, 1)))\(diff)")
//                }
//            }
            if !uniqueExpected.isEmpty {
//                closure("ExpectedSet missing:\n" + Array(uniqueExpected).map { $0.description }.joined())
                closure("ExpectedSet missing:\n\(indentation(level: max(level, 1)))" + results.joined(separator: "\(indentation(level: max(level, 1)))"))
            }
            return
        }
    case (.enum?, .enum?) where lhsMirror.children.first?.label != rhsMirror.children.first?.label,
         (.optional?, .optional?) where hasDiffNumOfChildren:
        closure("received: \"\(received)\" expected: \"\(expected)\"\n")
    default:
        break
    }

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
                    closure("child \(lhs.label ?? ""):\n\(indentation(level: level))" + results.joined(separator: "\(indentation(level: level))"))
                }
            } else {
                closure("\(lhs.label ?? "") received: \"\(rhs.value)\" expected: \"\(lhs.value)\"\n")
            }
        }
    }
}

private func indentation(level: Int) -> String {
    return (0..<level).reduce("") { acc, _ in acc + "\t" }
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
