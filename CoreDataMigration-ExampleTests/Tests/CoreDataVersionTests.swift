//
//  CoreDataVersionTests.swift
//  CoreDataMigration-ExampleTests
//
//  Created by William Boles on 29/03/2026.
//  Copyright © 2026 William Boles. All rights reserved.
//

import XCTest

@testable import CoreDataMigration_Example

class CoreDataVersionTests: XCTestCase {
    
    // MARK: - Tests
    
    // MARK: - RawValue
    
    func test_givenVersion1_ThenRawValueIsCorrect() {
        XCTAssertEqual(CoreDataVersion.version1.rawValue, "CoreDataMigration_Example")
    }
    
    func test_givenVersion2_ThenRawValueIsCorrect()  {
        XCTAssertEqual(CoreDataVersion.version2.rawValue, "CoreDataMigration_Example 2")
    }
    
    func test_givenVersion3_ThenRawValueIsCorrect()  {
        XCTAssertEqual(CoreDataVersion.version3.rawValue, "CoreDataMigration_Example 3")
    }
    
    func test_givenVersion4_ThenRawValueIsCorrect()  {
        XCTAssertEqual(CoreDataVersion.version4.rawValue, "CoreDataMigration_Example 4")
    }
    
    // MARK: - Latest

    func test_whenLatestIsCalled_ThenVersion4IsReturned() {
        XCTAssertEqual(CoreDataVersion.latest, .version4)
    }
}
