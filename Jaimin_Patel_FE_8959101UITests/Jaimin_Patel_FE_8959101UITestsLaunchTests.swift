//
//  Jaimin_Patel_FE_8959101UITestsLaunchTests.swift
//  Jaimin_Patel_FE_8959101UITests
//
//  Created by user237118 on 4/8/24.
//

import XCTest

final class Jaimin_Patel_FE_8959101UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
