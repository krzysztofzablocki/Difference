[![CircleCI](https://circleci.com/gh/krzysztofzablocki/Difference.svg?style=shield)](https://circleci.com/gh/krzysztofzablocki/Difference)
[![Version](https://img.shields.io/cocoapods/v/Difference.svg?style=flat)](http://cocoapods.org/pods/Difference)
[![License](https://img.shields.io/cocoapods/l/Difference.svg?style=flat)](http://cocoapods.org/pods/Difference)
[![Platform](https://img.shields.io/cocoapods/p/Difference.svg?style=flat)](http://cocoapods.org/pods/Difference)

# Difference

Better way to identify what's different between 2 instances.

Have you ever written tests? 
Usually they use equality asserts, e.g. `XCTAssertEqual`, what happens if the objects aren't equal? Xcode throws a wall of text at you:

![](Resources/before.png)

This forces you to manually scan the text and try to figure out exactly whats wrong, what if instead you could just learn which property is different?

![](Resources/after.png)

## Installation

### CocoaPods

Add `pod 'Difference'` to your Podfile.

### Carthage

Add `github "krzysztofzablocki/Difference"` to your Cartfile.

### SwiftPM

Add `.package(url: "https://github.com/krzysztofzablocki/Difference.git", .branch("master")),` dependency in your Package manifest.

## Using lldb

Just write the following to see the difference between 2 instances:

`po dumpDiff(expected, received)`


## Integrate with XCTest
Just add this to your test target:

```swift
public func AssertEqual<T: Equatable>(_ expected: T, _ received: T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(expected == received, "Found difference for \n" + diff(expected, received).joined(separator: ", "), file: file, line: line)
}
```

## Integrate with Quick
Just add this to your test target:

```swift
public func equalDiff<T: Equatable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.define { actualExpression in
        let receivedValue = try actualExpression.evaluate()

        if receivedValue == nil {
            var message = ExpectationMessage.fail("")
            if let expectedValue = expectedValue {
                message = ExpectationMessage.expectedCustomValueTo("equal <\(expectedValue)>", "nil")
            }
            return PredicateResult(status: .fail, message: message)
        }
        if expectedValue == nil {
            return PredicateResult(status: .fail, message: ExpectationMessage.fail("").appendedBeNilHint())
        }

        return PredicateResult(bool: receivedValue == expectedValue, message: ExpectationMessage.fail("Found difference for " + diff(expectedValue, receivedValue).joined(separator: ", ")))
    }
}
```
