//
//  DifferenceTests.swift
//  Difference
//
//  Created by Krzysztof Zablocki on 18.10.2017
//  Copyright © 2017 Krzysztof Zablocki. All rights reserved.
//

import Foundation
import XCTest
import Difference

fileprivate struct Person {
    let name: String
    let age: Int

    struct Address {
        let street: String
        let postCode: String

        struct ComplexCounter {
            let counter: Int
        }
        let counter: ComplexCounter
    }

    let address: Address
}


class DifferenceTests: XCTestCase {

    func testCanFindRootPrimitiveDifference() {
        let results = diff(2, 3)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "received: \"3\" expected: \"2\"\n")
    }

    fileprivate let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)))

    func testCanFindPrimitiveDifference() {
        let stub = Person(name: "Krzysztof", age: 30, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)))

        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "age received: \"30\" expected: \"29\"\n")
    }

    func testCanFindMultipleDifference() {
        let stub = Person(name: "Adam", age: 30, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)))

        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first, "name received: \"Adam\" expected: \"Krzysztof\"\n")
        XCTAssertEqual(results.last, "age received: \"30\" expected: \"29\"\n")
    }

    func testCanFindComplexDifference() {
        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "2nd Street", postCode: "00-1000", counter: .init(counter: 1)))

        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "child address:\nstreet received: \"2nd Street\" expected: \"Times Square\"\nchild counter:\n\tcounter received: \"1\" expected: \"2\"\n")
    }

    func test_canFindCollectionCountDifference() {
        let results = diff([1], [1, 3])

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "different count:\nreceived: \"[1, 3]\" (2)\nexpected: \"[1]\" (1)\n")
    }

    static var allTests = [
        ("testCanFindRootPrimitiveDifference", testCanFindRootPrimitiveDifference),
        ("testCanFindPrimitiveDifference", testCanFindPrimitiveDifference),
        ("testCanFindMultipleDifference", testCanFindMultipleDifference),
        ("testCanFindComplexDifference", testCanFindComplexDifference),
        ("test_canFindCollectionCountDifference", test_canFindCollectionCountDifference),
    ]
}
