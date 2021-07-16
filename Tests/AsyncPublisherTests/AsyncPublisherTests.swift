import XCTest
@testable import AsyncPublisher

final class AsyncPublisherTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AsyncPublisher().text, "Hello, World!")
    }
}
