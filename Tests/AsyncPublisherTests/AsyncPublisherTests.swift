import XCTest
import Combine
@testable import AsyncPublisher

final class AsyncPublisherTests: XCTestCase {
    func test_await_success() throws {
        var cancellables = Set<AnyCancellable>()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SuccessURLProtocol.self]

        URLSession(configuration: configuration).dataTaskPublisher(for: URL(string: "https://example.com")!)
            .await(timeout: .now() + .seconds(10))
            .map { _ in true }
            .sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    break
                case .failure:
                    XCTFail()
                }
            },
                  receiveValue: { XCTAssertTrue($0) })
            .store(in: &cancellables)
    }

    func test_await_error() throws {
        var cancellables = Set<AnyCancellable>()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ErrorURLProtocol.self]
        ErrorURLProtocol.error = URLError(.unknown)

        URLSession(configuration: configuration).dataTaskPublisher(for: URL(string: "https://example.com")!)
            .await(timeout: .now() + .seconds(10))
            .sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    XCTFail()
                case .failure(let error):

                    XCTAssertEqual(error.code, URLError(.unknown).code)
                }
            },
                  receiveValue: { _ in XCTFail() })
            .store(in: &cancellables)
    }

    func test_await_timeout() throws {
        var cancellables = Set<AnyCancellable>()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SuccessURLProtocol.self]

        URLSession(configuration: configuration).dataTaskPublisher(for: URL(string: "https://example.com")!)
            .await(timeout: .now())
            .sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    XCTFail()
                case .failure(let error):
                    XCTAssertEqual(error, URLError(.timedOut))
                }
            },
                  receiveValue: { _ in XCTFail() })
            .store(in: &cancellables)
    }
}
