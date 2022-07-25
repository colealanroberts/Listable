//
//  ItemPreviewAppearanceTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/14/20.
//

@testable import ListableUI
import XCTest

class ItemPreviewAppearanceTests: XCTestCase {
    func test_init() {
        let appearance = ItemPreviewAppearance()

        XCTAssertEqual(appearance.padding, 20.0)
        XCTAssertEqual(appearance.backgroundColor, .white)
    }
}
