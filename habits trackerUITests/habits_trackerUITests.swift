//
//  habits_trackerUITests.swift
//  habits trackerUITests
//
//  Created by Raphael Canguçu on 05/10/25.
//

import XCTest

final class habits_trackerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-StoreScreenshotMode",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()

        XCTAssertTrue(app.navigationBars["Vibe Habits"].waitForExistence(timeout: 8))
        sleep(3)
        captureStoreScreenshot(named: "01-habits")

        let insightsButton = app.buttons["Insights"].firstMatch
        XCTAssertTrue(insightsButton.waitForExistence(timeout: 3))
        insightsButton.tap()
        XCTAssertTrue(app.staticTexts["Insights"].waitForExistence(timeout: 3))
        captureStoreScreenshot(named: "02-insights")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Vibe Habits"].waitForExistence(timeout: 8))
        sleep(3)
        let feedTab = app.tabBars.buttons["Feed"].exists
            ? app.tabBars.buttons["Feed"]
            : app.buttons["Feed"].firstMatch
        XCTAssertTrue(feedTab.waitForExistence(timeout: 3))
        feedTab.tap()
        XCTAssertTrue(app.navigationBars["Feed"].waitForExistence(timeout: 3))
        captureStoreScreenshot(named: "03-feed")
    }

    private func captureStoreScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
