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
    let petAges: [String: Int]
}

private enum State {
    case loaded([Int], String)
    case anotherLoaded([Int], String)
}

private func dumpDiffSurround<T>(_ lhs: T, _ rhs: T) {
    print("====START DIFF====")
    dumpDiff(lhs, rhs)
    print("=====END DIFF=====")
}

class DifferenceTests: XCTestCase {

    func testCanFindRootPrimitiveDifference() {
//        dumpDiffSurround(2, 3)
        let results = diff(2, 3)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R7Received: 3\nExpected: 2\n")
    }

    fileprivate let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: [:])

    func testCanFindPrimitiveDifference() {
        let stub = Person(name: "Krzysztof", age: 30, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: [:])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R9Child age:\nR6|\tReceived: 30\n|\tExpected: 29\n")

    }

    func testCanFindMultipleDifference() {
        let stub = Person(name: "Adam", age: 30, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: [:])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first, "R9Child name:\nR6|\tReceived: Adam\n|\tExpected: Krzysztof\n")
        XCTAssertEqual(results.last, "R9Child age:\nR6|\tReceived: 30\n|\tExpected: 29\n")
    }

    func testCanFindComplexDifference() {
        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "2nd Street", postCode: "00-1000", counter: .init(counter: 1)), pet: nil, petAges: [:])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Child address:\nR9|\tChild street:\nR6|\t|\tReceived: 2nd Street\n|\t|\tExpected: Times Square\nR8|\tChild counter:\nR9|\t|\tChild counter:\nR6|\t|\t|\tReceived: 1\n|\t|\t|\tExpected: 2\n")

    }

    func testCanGiveDescriptionForOptionalOnLeftSide() {
        let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: [:])

        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: .init(name: "Fluffy"), petAges: [:])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)
        XCTAssertEqual(results.count, 1)
    }

    func testCanGiveDescriptionForOptionalOnRightSide() {
        let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: .init(name: "Fluffy"), petAges: [:])

        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: [:])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)
        XCTAssertEqual(results.count, 1)
    }

    func test_canFindCollectionCountDifference() {
        dumpDiffSurround([1], [1, 3])

        let results = diff([1], [1, 3])

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R10Different count:\nR1|\tReceived: (2) [1, 3]\n|\tExpected: (1) [1]\n")
    }

    func test_canFindCollectionCountDifference_complex() {
        let truth = State.loaded([1, 2], "truth")
        let stub = State.loaded([], "stub")
//        dumpDiffSurround(truth, stub)

        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Enum loaded:\nR8|\tChild .0:\nR10|\t|\tDifferent count:\nR1|\t|\t|\tReceived: (0) []\n|\t|\t|\tExpected: (2) [1, 2]\nR9|\tChild .1:\nR6|\t|\tReceived: stub\n|\t|\tExpected: truth\n")
    }

    func test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical() {
        let truth = State.loaded([0], "CommonString")
        let stub = State.anotherLoaded([0], "CommonString")

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R5Received: anotherLoaded\nExpected: loaded\n")
    }

    func test_canFindDictionaryCountDifference() {
        let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: .init(name: "Fluffy"), petAges: ["Max": 4, "Jethro": 6])

        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: ["Max": 1, "Jethro": 2])

        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "received: \"[:]\" expected: \"[\"A\": \"B\"]\"\n")
    }

//    func test_canFindDictionaryCountDifference_complex() {
//        let truth = ["A": "B"]
//        let stub = Dictionary<String, String>()
//
//        dumpDiffSurround(truth, stub)
//        let results = diff(truth, stub)
//
//        XCTAssertEqual(results.count, 1)
//        XCTAssertEqual(results.first, "received: \"[:]\" expected: \"[\"A\": \"B\"]\"\n")
//    }

//    func test_canFindOptionalDifferenceBetweenSomeAndNone() {
//        let results = diff(["A": "B"], nil)
//
//        XCTAssertEqual(results.count, 1)
//        XCTAssertEqual(results.first, "received: \"nil\" expected: \"Optional([\"A\": \"B\"])\"\n")
//    }
//
//    func test_canFindDictionaryDifference() {
//        let results = diff(
//            [
//                "a": 1,
//                "b": 3,
//                "c": 3,
//                "d": 4,
//            ],
//            [
//                "a": 1,
//                "b": 2,
//                "c": 3,
//                "d": 0,
//            ]
//        )
//
//        // TODO: Should results.count be 2?
//        XCTAssertEqual(results.count, 2)
//        XCTAssertEqual(results.first, "")
//    }
//
//    func test_set() {
//        (0..<1000).forEach { _ in
//            let expected: Set<Int> = [1, 2, 3, 4, 5]
//            let actual: Set<Int> = [7, 6, 5, 4, 3]
//
//            let results = diff(expected, actual)
//
//            XCTAssertEqual(results.count, 1)
//                // Need to figure out how to get consistent ordering of a set in the result. Alternately, reduce this test to only 1 diff.
//            XCTAssertEqual(results.first!, "Set mismatch:\n\tvalue received: \"7\" expected: \"2\"\n\tvalue received: \"6\" expected: \"1\"\n" )
//        }
//    }
//
//    func test_inner_set() {
//        let expectedAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [1, 2, 3, 4, 5], dictionaryOfInts: ["a":1])
//        let actualAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [3, 4, 5, 6, 7], dictionaryOfInts: ["a":2])
//
//        let newPersonExpected = NewPerson(name: "Krzysztof", age: 29, address: expectedAddress, secondAddress: expectedAddress, pet: nil)
//        let newPersonActual = NewPerson(name: "Krzysztof", age: 29, address: actualAddress, secondAddress: actualAddress, pet: nil)
//
//        let results = diff(newPersonExpected, newPersonActual)
//        dumpDiff(newPersonExpected, newPersonActual)
//
//        XCTAssertEqual(results.first!, "" )
//        print("@@@@@@@@@@@@")
//        print(results.first!)
//        print("@@@@@@@@@@@@")
//     }
//
//    func test_inner_dict() {
//        let expectedDicts = [
//            "a": 1,
//            "b": 3,
//            "c": 3,
//            "d": 4,
//        ]
//        let actualDicts = [
//            "a": 1,
//            "b": 2,
//            "c": 6,
//            "d": 0,
//        ]
//
//        let expectedAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [], dictionaryOfInts: expectedDicts)
//        let actualAddress = NewPerson.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2), setOfInts: [], dictionaryOfInts: actualDicts)
//
//        let newPersonExpected = NewPerson(name: "Krzysztof", age: 29, address: expectedAddress, secondAddress: expectedAddress, pet: nil)
//        let newPersonActual = NewPerson(name: "Krzysztof", age: 29, address: actualAddress, secondAddress: actualAddress, pet: nil)
//
//        let results = diff(newPersonExpected, newPersonActual)
//
//        dumpDiff(newPersonExpected, newPersonActual)
//        XCTAssertEqual(results.first!, "" )
//        print(results.joined(separator: "\n"))
//
//     }
//
//    func test_multiple_child_failures() {
//        let expectedContainer = Container1(
//            topValue: 1,
//            container2: .init(
//                value: 2,
//                container3: .init(
//                    value: 3,
//                    container4: .init(value: 4)
//                )
//            )
//        )
//
//        let actualContainer = Container1(
//            topValue: -1,
//            container2: .init(
//                value: -2,
//                container3: .init(
//                    value: -3,
//                    container4: .init(value: -4)
//                )
//            )
//        )
//
//        let results = diff(expectedContainer, actualContainer)
//
//        print("@@@@@@@@@@@@")
//        print(results.joined(separator: "\n"))
//        print("@@@@@@@@@@@@")
//    }
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
