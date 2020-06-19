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
    case loadedWithDiffArguments(Int)
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

    // MARK: Collections

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

    // MARK: Enums

    func test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical() {
        let truth = State.loaded([0], "CommonString")
        let stub = State.anotherLoaded([0], "CommonString")

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R5Received: anotherLoaded\nExpected: loaded\n")
    }

    func test_canFindEnumCaseDifferenceWhenLessArguments() {
        let truth = State.loaded([0], "CommonString")
        let stub = State.loadedWithDiffArguments(1)

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R5Received: loadedWithDiffArguments\nExpected: loaded\n")
    }

    // MARK: Dictionaries

    func test_canFindDictionaryCountDifference() {
        let truth = Person(petAges: ["Henny": 4])
        let stub = Person(petAges: [:])

        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Child petAges:\nR8|\tChild some:\nR10|\t|\tDifferent count:\nR1|\t|\t|\tReceived: (0) [:]\n|\t|\t|\tExpected: (1) [\"Henny\": 4]\n")
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

    // MARK: Sets

    func test_canFindSetCountDifference() {
        let truth = Person(favoriteFoods: [])
        let stub = Person(favoriteFoods: ["Oysters"])

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Child favoriteFoods:\nR8|\tChild some:\nR10|\t|\tDifferent count:\nR1|\t|\t|\tReceived: (1) [\"Oysters\"]\n|\t|\t|\tExpected: (0) []\n")
    }

    func test_canFindOptionalSetDifferenceBetweenSomeAndNone() {
        let truth = Person(favoriteFoods: ["Oysters"])
        let stub = Person(favoriteFoods: nil)

//        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, "R8Child favoriteFoods:\nR7|\tReceived: nil\n|\tExpected: Optional(Set([\"Oysters\"]))\n")
    }

    func test_canFindSetDifference() {
        let truth = Person(favoriteFoods: ["Sushi", "Pizza"])
        let stub = Person(favoriteFoods: ["Oysters", "Crab"])

        dumpDiffSurround(truth, stub)
        let results = diff(truth, stub)

        XCTAssertEqual(results.count, 1)
        let header = "R8Child favoriteFoods:\nR8|\tChild some:\n"
        let sushiDiff = "R3|\t|\tMissing: Sushi\n"
        let pizzaDiff = "R3|\t|\tMissing: Pizza\n"
        let firstPermutation = header + sushiDiff + pizzaDiff
        let secondPermutation = header + pizzaDiff + sushiDiff
        XCTAssertTrue(assertEither(expected: (firstPermutation, secondPermutation), received: results.first))
    }
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
