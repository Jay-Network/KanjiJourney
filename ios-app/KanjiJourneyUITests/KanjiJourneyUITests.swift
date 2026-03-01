import XCTest

final class KanjiJourneyUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchAndLogin() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify login screen appears
        XCTAssertTrue(app.staticTexts["KanjiJourney"].exists)
    }
}
