//
//  VolumeOSTests.swift
//  VolumeOSTests
//
//  Created by Rishan Subagar on 2025-12-30.
//

import XCTest
@testable import VolumeOS

final class VolumeOSTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVolumeLevel() throws {
        let vol = VolumeLevel(0.5)
        XCTAssertEqual(vol.normalized, 0.5)
        XCTAssertEqual(vol.percentage, 50)

        let cappedVol = VolumeLevel(1.5)
        XCTAssertEqual(cappedVol.normalized, 1.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
