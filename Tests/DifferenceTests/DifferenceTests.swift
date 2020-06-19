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
    let address: Address
    let pet: Pet?
    let petAges: [String: Int]?
    let favoriteFoods: Set<String>?

    init(
        name: String = "Krzysztof",
        age: Int = 29,
        address: Address = .init(),
        pet: Pet? = .init(),
        petAges: [String: Int]? = nil,
        favoriteFoods: Set<String>? = nil
    ) {
        self.name = name
        self.age = age
        self.address = address
        self.pet = pet
        self.petAges = petAges
        self.favoriteFoods = favoriteFoods
    }

    struct Address: Equatable {
        let street: String
        let postCode: String
        let counter: ComplexCounter

        init(
            street: String = "Times Square",
            postCode: String = "00-1000",
            counter: ComplexCounter = .init()
        ) {
            self.street = street
            self.postCode = postCode
            self.counter = counter
        }

        struct ComplexCounter: Equatable {
            let counter: Int

            init(counter: Int = 2) {
                self.counter = counter
            }
        }
    }

    struct Pet: Equatable {
        let name: String

        init(name: String = "Fluffy") {
            self.name = name
        }
    }
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

    fileprivate let truth = Person()

    func testCanFindPrimitiveDifference() {
        let stub = Person(age: 30)

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R9Child age:\nR6|\tReceived: 30\n|\tExpected: 29\n")

    }

    func testCanFindMultipleDifference() {
        let stub = Person(name: "Adam", age: 30)

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first, "R9Child name:\nR6|\tReceived: Adam\n|\tExpected: Krzysztof\n")
        XCTAssertEqual(results.last, "R9Child age:\nR6|\tReceived: 30\n|\tExpected: 29\n")
    }

    func testCanFindComplexDifference() {
        let stub = Person(address: Person.Address(street: "2nd Street", counter: .init(counter: 1)))

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Child address:\nR9|\tChild street:\nR6|\t|\tReceived: 2nd Street\n|\t|\tExpected: Times Square\nR8|\tChild counter:\nR9|\t|\tChild counter:\nR6|\t|\t|\tReceived: 1\n|\t|\t|\tExpected: 2\n")

    }

    func testCanGiveDescriptionForOptionalOnLeftSide() {
        let truth = Person(pet: nil)

        let stub = Person()

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)
        XCTAssertEqual(results.count, 1)
    }

    func testCanGiveDescriptionForOptionalOnRightSide() {
        let truth = Person()

        let stub = Person(pet: nil)

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)
        XCTAssertEqual(results.count, 1)
    }

    func test_canFindCollectionCountDifference() {
//        dumpDiffSurround([1], [1, 3])

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
        let truth = Person(petAges: ["Henny": 4, "Jethro": 6])

        let stub = Person(petAges: ["Henny": 1])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Child petAges:\nR8|\tChild some:\nR10|\t|\tDifferent count:\nR1|\t|\t|\tReceived: (1) [\"Henny\": 1]\n|\t|\t|\tExpected: (2) [\"Henny\": 4, \"Jethro\": 6]\n")
    }

    func test_canFindOptionalDifferenceBetweenSomeAndNone() {
        let truth = Person(petAges: ["Henny": 4, "Jethro": 6])

        let stub = Person(petAges: nil)

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        let header = "R8Child petAges:\nR7|\tReceived: nil\n|\tExpected: Optional(["
        let hennyDiff = "\"Henny\": 4"
        let jethroDiff = "\"Jethro\": 6"
        let endingDiff = "])\n"
        let firstPermutation = header + hennyDiff + ", " + jethroDiff + endingDiff
        let secondPermutation = header + jethroDiff + ", " + hennyDiff + endingDiff
        XCTAssertTrue(assertEither(expected: (firstPermutation, secondPermutation), received: results.first))
    }

    func test_canFindDictionaryDifference() {
        let truth = Person(petAges: ["Henny": 4, "Jethro": 6])

        let stub = Person(petAges: ["Henny": 1, "Jethro": 2])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        let header = "R8Child petAges:\nR8|\tChild some:\n"
        let jethroDiff = "R2|\t|\tChild key Jethro:\nR9|\t|\t|\tChild some:\nR6|\t|\t|\t|\tReceived: 2\n|\t|\t|\t|\tExpected: 6\n"
        let hennyDiff = "R2|\t|\tChild key Henny:\nR9|\t|\t|\tChild some:\nR6|\t|\t|\t|\tReceived: 1\n|\t|\t|\t|\tExpected: 4\n"
        let firstPermutation = header + jethroDiff + hennyDiff
        let secondPermutation = header + hennyDiff + jethroDiff
        XCTAssertTrue(assertEither(expected: (firstPermutation, secondPermutation), received: results.first))
    }

    func test_canFindSetCountDifferent() {
        let truth = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: ["Henny": 4, "Jethro": 6])

        let stub = Person(name: "Krzysztof", age: 29, address: Person.Address(street: "Times Square", postCode: "00-1000", counter: .init(counter: 2)), pet: nil, petAges: ["Henny": 1])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Child petAges:\nR8|\tChild some:\nR10|\t|\tDifferent count:\nR1|\t|\t|\tReceived: (1) [\"Henny\": 1]\n|\t|\t|\tExpected: (2) [\"Henny\": 4, \"Jethro\": 6]\n")
    }

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

private func assertEither<T: Equatable>(
    expected: (T, T),
    received: T
) -> Bool {
    if expected.0 == received {
        return true
    } else if expected.1 == received {
        return true
    } else {
        return false
    }
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
