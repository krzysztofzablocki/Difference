[![CircleCI](https://circleci.com/gh/krzysztofzablocki/Difference.svg?style=shield)](https://circleci.com/gh/krzysztofzablocki/Difference)
[![Version](https://img.shields.io/cocoapods/v/Difference.svg?style=flat)](http://cocoapods.org/pods/Difference)
[![License](https://img.shields.io/cocoapods/l/Difference.svg?style=flat)](http://cocoapods.org/pods/Difference)
[![Platform](https://img.shields.io/cocoapods/p/Difference.svg?style=flat)](http://cocoapods.org/pods/Difference)

# Difference

Better way to identify whats different between 2 instances.

Have you ever written tests? 
Usually they use equality asserts, e.g. `XCTAssertEqual`, what happens if the object aren't equal ? Xcode throws wall of text at you:

![](Resources/before.png)

This forces you to manually scan the text and try to figure out exactly whats wrong, what if instead you could just learn which property is different?

![](Resources/after.png)

## Using lldb

Just write following to see difference between 2 instances:

`po dumpDiff(expected, received)`


## Integrate with XCTest
Just add this to your test target:

```swift
public func AssertEqual<T: Equatable>(_ expected: T, _ received: T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(expected == received, "Found difference for " + diff(expected, received).joined(separator: ", "), file: file, line: line)
}
```

## Integrate with Quick
Just add this to your test target:

```swift
public func equalDiff<T: Equatable>(_ otherObject: T?) -> Predicate<T> {
    return Predicate.define { actualExpression in
        guard let otherObject = otherObject else {
            return PredicateResult(status: .fail, message: ExpectationMessage.fail("").appendedBeNilHint())
        }

        let object = try actualExpression.evaluate()

        return PredicateResult(bool: object != otherObject, message: ExpectationMessage.fail("Found difference for " + diff(object, otherObject).joined(separator: ", ")))
    }
}
```