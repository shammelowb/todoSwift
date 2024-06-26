import XCTest
@testable import todo

final class AppTests: XCTestCase {
    func testCommandFromUser() {
        let app = App()
        XCTAssert(app.command == .list)
    }
}
