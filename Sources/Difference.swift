import Foundation

fileprivate func handleChildless<T>(
    _ expected: T,
    _ received: T,
    _ indentationLevel: Int
) -> String {
    let expectedMirror = Mirror(reflecting: expected)
    let receivedMirror = Mirror(reflecting: received)

    guard !expectedMirror.canBeEmpty else {
        return generateDifferentCountBlock(expected, expectedMirror, received, receivedMirror, indentationLevel)
    }

    let receivedPrintable: String
    let expectedPrintable: String
    if receivedMirror.children.count == 0, expectedMirror.children.count != 0 {
        receivedPrintable = String(dumping: received)
        expectedPrintable = enumLabelFromFirstChild(expectedMirror) ?? String(describing: expected)
    } else if expectedMirror.children.count == 0, receivedMirror.children.count != 0 {
        receivedPrintable = enumLabelFromFirstChild(receivedMirror) ?? String(describing: received)
        expectedPrintable = String(dumping: expected)
    } else {
        receivedPrintable = String(describing: received)
        expectedPrintable = String(describing: expected)
    }
    return generateExpectedReceiveBlock(expectedPrintable, receivedPrintable, indentationLevel)
}

private func generateDifferentCountBlock<T>(
    _ expected: T,
    _ expectedMirror: Mirror,
    _ received: T,
    _ receivedMirror: Mirror,
    _ indentationLevel: Int
) -> String {
    let expectedPrintable = "(\(expectedMirror.children.count)) \(expected)"
    let receivedPrintable = "(\(receivedMirror.children.count)) \(received)"
    let header = "\(indentation(level: indentationLevel))Different count:\n"
    return header + generateExpectedReceiveBlock(expectedPrintable, receivedPrintable, indentationLevel + 1)
}

/// Compares 2 objects and iterates over their differences
///
/// - Parameters:
///   - lhs: expected object
///   - rhs: received object
///   - closure: iteration closure
fileprivate func diff<T>(_ expected: T, _ received: T, level: Int = 0, closure: (_ description: String) -> Void) {
    let expectedMirror = Mirror(reflecting: expected)
    let receivedMirror = Mirror(reflecting: received)

    guard expectedMirror.children.count != 0, receivedMirror.children.count != 0 else {
        if String(dumping: received) != String(dumping: expected) {
            closure(handleChildless(expected, received, level))
        }
        return
    }

    let hasDiffNumOfChildren = expectedMirror.children.count != receivedMirror.children.count
    switch (expectedMirror.displayStyle, receivedMirror.displayStyle) {
    case (.collection?, .collection?) where hasDiffNumOfChildren,
         (.dictionary?, .dictionary?) where hasDiffNumOfChildren,
         (.set?, .set?) where hasDiffNumOfChildren:
        let toPrint = generateDifferentCountBlock(expected, expectedMirror, received, receivedMirror, level)
        closure(toPrint)
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
                    let header = "\(indentation(level: level))Key \(key.description):\n"
                    closure(header + results.joined())
                }
            }
            return
        }

    case (.set?, .set?):
        if let expectedSet = expected as? Set<AnyHashable>,
            let receivedSet = received as? Set<AnyHashable> {
            let uniqueExpected = expectedSet.subtracting(receivedSet)

            var results = [String]()
            uniqueExpected.forEach { unique in
                results.append("\(indentation(level: level))Missing: \(unique.description)\n")
            }

            if !uniqueExpected.isEmpty {
                closure(results.joined())
            }
            return
        }
    case (.enum?, .enum) where hasDiffNumOfChildren:
        closure("""
            Different count:
            \(indentation(level: level))Received: \(received) (\(receivedMirror.children.count))
            \(indentation(level: level))Expected: \(expected) (\(expectedMirror.children.count))\n
            """)
        return
    case (.enum?, .enum?) where expectedMirror.children.first?.label != receivedMirror.children.first?.label:
        let expectedPrintable = expectedMirror.children.first?.label ?? "UNKNOWN"
        let receivedPrintable = receivedMirror.children.first?.label ?? "UNKNOWN"

        closure(generateExpectedReceiveBlock(expectedPrintable, receivedPrintable, level))
        return
    default:
        break
    }

    let zipped = zip(expectedMirror.children, receivedMirror.children)
    zipped.enumerated().forEach { (index, zippedValues) in
        let lhs = zippedValues.0
        let rhs = zippedValues.1
        let leftDump = String(dumping: lhs.value)
        if leftDump != String(dumping: rhs.value) {
            if Mirror(reflecting: lhs.value).displayStyle != nil {
                var results = [String]()
                diff(lhs.value, rhs.value, level: level + 1) { diff in
                    results.append(diff)
                }
                if !results.isEmpty {
                    closure("\(indentation(level: level))\(expectedMirror.displayStyleDescriptor(index: index))\(lhs.label ?? ""):\n" + results.joined())
                }
            } else {
                let childName = "\(indentation(level: level))\(expectedMirror.displayStyleDescriptor(index: index))\(lhs.label ?? ""):\n"
                closure(childName + generateExpectedReceiveBlock(String(describing: lhs.value), String(describing: rhs.value), level + 1))
            }
        }
    }
}

private func generateExpectedReceiveBlock(
    _ expected: String,
    _ received: String,
    _ indentationLevel: Int
) -> String {
    let indentationSpacing = indentation(level: indentationLevel)
    return """
    \(indentationSpacing)Received: \(received)
    \(indentationSpacing)Expected: \(expected)

    """
}

fileprivate extension String {
    init<T>(dumping object: T) {
        self.init()
        dump(object, to: &self)
        self = withoutDumpArtifacts
    }

    private var withoutDumpArtifacts: String {
        self.replacingOccurrences(of: "- ", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}

private func enumLabelFromFirstChild(_ mirror: Mirror) -> String? {
    switch mirror.displayStyle {
    case .enum: return mirror.children.first?.label
    default: return nil
    }
}

fileprivate extension Mirror {
    func displayStyleDescriptor(index: Int) -> String {
        switch self.displayStyle {
        case .enum: return "Enum "
        case .collection: return "Collection[\(index)]"
        default: return ""
        }
    }

    // Used to show "different count" message if mirror has no children,
    // as some displayStyles can have 0 children.
    var canBeEmpty: Bool {
        switch self.displayStyle {
        case .collection,
             .dictionary,
             .set:
            return true
        default:
            return false
        }
    }
}

private func indentation(level: Int) -> String {
    return (0..<level).reduce("") { acc, _ in acc + "|\t" }
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
