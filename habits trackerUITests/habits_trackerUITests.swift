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
        try captureStoreFlow(language: "en", locale: "en_US")
    }

    @MainActor
    func testStoreScreenshotsPortuguese() throws {
        try captureStoreFlow(language: "pt-BR", locale: "pt_BR")
    }

    @MainActor
    private func captureStoreFlow(language: String, locale: String) throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments += [
            "-StoreScreenshotMode",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale
        ]
        app.launch()

        XCTAssertTrue(app.navigationBars["Vibe Habits"].waitForExistence(timeout: 8))
        sleep(3)
        captureStoreScreenshot(named: "\(language)-01-habits")

        let insightsButton = app.buttons[language == "pt-BR" ? "Análises" : "Insights"].firstMatch
        XCTAssertTrue(insightsButton.waitForExistence(timeout: 3))
        insightsButton.tap()
        XCTAssertTrue(app.staticTexts[language == "pt-BR" ? "Análises" : "Insights"].waitForExistence(timeout: 3))
        captureStoreScreenshot(named: "\(language)-02-insights")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Vibe Habits"].waitForExistence(timeout: 8))
        sleep(3)
        let addHabitButton = app.buttons[language == "pt-BR" ? "Adicionar hábito" : "Add habit"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3))
        addHabitButton.tap()
        let newHabitTitle = language == "pt-BR" ? "Novo hábito" : "New Habit"
        XCTAssertTrue(app.navigationBars[newHabitTitle].waitForExistence(timeout: 3))
        let reminderLabel = language == "pt-BR" ? "Lembrar-me" : "Remind me"
        let reminderToggle = app.switches[reminderLabel]
        XCTAssertTrue(reminderToggle.waitForExistence(timeout: 3))
        XCTAssertEqual(reminderToggle.value as? String, "1")
        app.swipeUp()
        captureStoreScreenshot(named: "\(language)-03-reminder")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Vibe Habits"].waitForExistence(timeout: 8))
        sleep(3)
        let settingsLabel = language == "pt-BR" ? "Ajustes" : "Settings"
        let settingsTab = app.tabBars.buttons[settingsLabel].exists
            ? app.tabBars.buttons[settingsLabel]
            : app.buttons[settingsLabel].firstMatch
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 3))
        settingsTab.tap()
        XCTAssertTrue(app.navigationBars[settingsLabel].waitForExistence(timeout: 3))
        sleep(1)
        let exportLabel = language == "pt-BR" ? "Exportar backup" : "Export Backup"
        XCTAssertTrue(app.buttons[exportLabel].waitForExistence(timeout: 3))
        captureStoreScreenshot(named: "\(language)-04-private-backup")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Vibe Habits"].waitForExistence(timeout: 8))
        sleep(3)
        let feedLabel = language == "pt-BR" ? "Histórico" : "Feed"
        let feedTab = app.tabBars.buttons[feedLabel].exists
            ? app.tabBars.buttons[feedLabel]
            : app.buttons[feedLabel].firstMatch
        XCTAssertTrue(feedTab.waitForExistence(timeout: 3))
        feedTab.tap()
        XCTAssertTrue(app.navigationBars[feedLabel].waitForExistence(timeout: 3))
        captureStoreScreenshot(named: "\(language)-05-feed")
    }

    private func captureStoreScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
