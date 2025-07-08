//
//  Sample.swift
//  SwiftUIBugsTests
//
//  Created by ASHOK DY on 2025-07-07.
//

import Testing
@testable import SwiftUIBugs


struct Sample {

    @Test func fullName() {
        let person = Person(firstName: "Antoine", lastName: "van der Lee")
        #expect(person != nil, "Person should be constructed successfully")
        #expect(person?.fullName == "Antoine van der Lee")
    }
    
    @Test(
        .timeLimit(.minutes(1))
    )
    func fullName2() throws {
        let person = Person(firstName: "Antoine", lastName: "van der Lee")
        try #require(person != nil, "Person should be constructed successfully")
        #expect(person?.fullName == "Antoine van der Lee")
    }
    
    @Test func emptyName() throws {
        let person = Person(firstName: "van", lastName: "der Lee")
        let unwrappedPerson = try #require(person, "Person should be constructed successfully")
        #expect(unwrappedPerson.fullName == "van der Lee")
    }
}
