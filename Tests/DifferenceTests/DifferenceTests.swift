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

fileprivate struct Person: Equatable {
    let name: String
    let age: Int

    struct Address: Equatable {
        let street: String
        let postCode: String

        struct ComplexCounter: Equatable {
            let counter: Int
        }
        let counter: ComplexCounter
    }
    
    struct Pet: Equatable {
        let name: String
    }

    let address: Address
    let pet: Pet?
}

private enum State {
    case loaded([Int])
    case anotherLoaded([Int])
}

class DifferenceTests: XCTestCase {

    func testCanFindRootPrimitiveDifference() {
        let results = diff(2, 3)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "received: \"3\" expected: \"2\"\n")
    }

    fileprivate let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil)

    func testCanFindPrimitiveDifference() {
        let stub = Person(name: "Krzysztof", age: 30, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil)

        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "age received: \"30\" expected: \"29\"\n")

    }

    func testCanFindMultipleDifference() {
        let stub = Person(name: "Adam", age: 30, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil)

        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first, "name received: \"Adam\" expected: \"Krzysztof\"\n")
        XCTAssertEqual(results.last, "age received: \"30\" expected: \"29\"\n")
    }

    func testCanFindComplexDifference() {
        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "2nd Street", postCode: "00-1000", counter: .init(counter: 1)), pet: nil)

        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "child address:\nstreet received: \"2nd Street\" expected: \"Times Square\"\nchild counter:\n\tcounter received: \"1\" expected: \"2\"\n")
    }

    func testCanGiveDescriptionForOptionalOnLeftSide() {
        let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil)

        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: .init(name: "Fluffy"))

        let results = diff(truth, stub)
        XCTAssertEqual(results.count, 1)
    }

    func testCanGiveDescriptionForOptionalOnRightSide() {
        let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: .init(name: "Fluffy"))

        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil)

        let results = diff(truth, stub)
        XCTAssertEqual(results.count, 1)
    }

    func test_canFindCollectionCountDifference() {
        let results = diff([1], [1, 3])

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "different count:\nreceived: \"[1, 3]\" (2)\nexpected: \"[1]\" (1)\n")
    }

    func test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical() {
        let results = diff(State.loaded([0]), State.anotherLoaded([0]))

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "received: \"anotherLoaded([0])\" expected: \"loaded([0])\"\n")
    }

    func test_canFindDictionaryCountDifference() {
        let results = diff(["A": "B"], [:])

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "received: \"[:]\" expected: \"[\"A\": \"B\"]\"\n")
    }

    func test_canFindOptionalDifferenceBetweenSomeAndNone() {
        let results = diff(["A": "B"], nil)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "received: \"nil\" expected: \"Optional([\"A\": \"B\"])\"\n")
    }

    func test_canFindDictionaryDifference() {
        let results = diff(
            [
                "a": 1,
                "b": 3,
                "c": 3,
                "d": 4,
            ],
            [
                "a": 1,
                "b": 2,
                "c": 3,
                "d": 0,
            ]
        )

        // TODO: Should results.count be 2?
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first, "")
    }

    func test_set() {
        (0..<1000).forEach { _ in
            let expected: Set<Int> = [1, 2, 3, 4, 5]
            let actual: Set<Int> = [7, 6, 5, 4, 3]

            let results = diff(expected, actual)

            XCTAssertEqual(results.count, 1)
                // Need to figure out how to get consistent ordering of a set in the result. Alternately, reduce this test to only 1 diff.
            XCTAssertEqual(results.first!, "Set mismatch:\n\tvalue received: \"7\" expected: \"2\"\n\tvalue received: \"6\" expected: \"1\"\n" )
        }
    }

    func test_inner_set() {
        let expectedAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [1, 2, 3, 4, 5], dictionaryOfInts: [:])
        let actualAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [3, 4, 5, 6, 7], dictionaryOfInts: [:])

        let newPersonExpected = NewPerson(name: "Krzysztof", age: 29, address: expectedAddress, secondAddress: expectedAddress, pet: nil)
        let newPersonActual = NewPerson(name: "Krzysztof", age: 29, address: actualAddress, secondAddress: actualAddress, pet: nil)

        let results = diff(newPersonExpected, newPersonActual)

        XCTAssertEqual(results.first!, "" )
        print("@@@@@@@@@@@@")
        print(results.first!)
        print("@@@@@@@@@@@@")
     }

    func test_inner_dict() {
        let expectedDicts = [
            "a": 1,
            "b": 3,
            "c": 3,
            "d": 4,
        ]
        let actualDicts = [
            "a": 1,
            "b": 2,
            "c": 6,
            "d": 0,
        ]

        let expectedAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [], dictionaryOfInts: expectedDicts)
        let actualAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [], dictionaryOfInts: actualDicts)

        let newPersonExpected = NewPerson(name: "Krzysztof", age: 29, address: expectedAddress, secondAddress: expectedAddress, pet: nil)
        let newPersonActual = NewPerson(name: "Krzysztof", age: 29, address: actualAddress, secondAddress: actualAddress, pet: nil)

        let results = diff(newPersonExpected, newPersonActual)

        XCTAssertEqual(results.first!, "" )
        print(results.joined(separator: "\n"))

     }

    func test_multiple_child_failures() {
        let expectedContainer = Container1(
            topValue: 1,
            container2: .init(
                value: 2,
                container3: .init(
                    value: 3,
                    container4: .init(value: 4)
                )
            )
        )

        let actualContainer = Container1(
            topValue: -1,
            container2: .init(
                value: -2,
                container3: .init(
                    value: -3,
                    container4: .init(value: -4)
                )
            )
        )

        let results = diff(expectedContainer, actualContainer)

        print("@@@@@@@@@@@@")
        print(results.joined(separator: "\n"))
        print("@@@@@@@@@@@@")
    }
//
//    static var allTests = [
//        ("testCanFindRootPrimitiveDifference", testCanFindRootPrimitiveDifference),
//        ("testCanFindPrimitiveDifference", testCanFindPrimitiveDifference),
//        ("testCanFindMultipleDifference", testCanFindMultipleDifference),
//        ("testCanFindComplexDifference", testCanFindComplexDifference),
//        ("test_canFindCollectionCountDifference", test_canFindCollectionCountDifference),
//        ("test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical", test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical),
//        ("test_canFindDictionaryCountDifference", test_canFindDictionaryCountDifference),
//        ("test_canFindOptionalDifferenceBetweenSomeAndNone", test_canFindOptionalDifferenceBetweenSomeAndNone),
//        ("test_canFindDictionaryDifference", test_canFindDictionaryDifference)
//    ]
}

fileprivate struct Container1: Equatable {
    let topValue: Int
    let container2: Container2

    struct Container2: Equatable {
        let value: Int
        let container3: Container3

        struct Container3: Equatable {
            let value: Int
            let container4: Container4

            struct Container4: Equatable {
                let value: Int
            }
        }
    }
}

fileprivate struct NewPerson: Equatable {
    let name: String
    let age: Int

    struct Address: Equatable {
        let street: String
        let postCode: String

        struct ComplexCounter: Equatable {
            let counter: Int
        }
        let counter: ComplexCounter

        let setOfInts: Set<Int>
        let dictionaryOfInts: [String: Int]
    }

    struct Pet: Equatable {
        let name: String
    }

    let address: Address
    let secondAddress: Address
    let pet: Pet?
}
