import Foundation
import XCTest
@testable import SimpleMovie

final class TMDBClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.requestHandler = nil
        super.tearDown()
    }

    @MainActor
    func testSendAddsBearerTokenAndDecodesSuccessfulResponse() async throws {
        let session = makeSession()
        let sut = TMDBClient(accessToken: "token", session: session)
        var capturedRequest: URLRequest?
        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                #"{"value":"success"}"#.data(using: .utf8)!
            )
        }

        let response: ResponseStub = try await sut.send(.movieDetails(id: 1))

        XCTAssertEqual(response.value, "success")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "accept"), "application/json")
    }

    @MainActor
    func testSendThrowsHTTPStatusErrorForNonSuccessfulResponse() async {
        let session = makeSession()
        let sut = TMDBClient(accessToken: "token", session: session)
        URLProtocolStub.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 404,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }

        do {
            let _: ResponseStub = try await sut.send(.movieDetails(id: 1))
            XCTFail("Expected request to fail")
        } catch let error as TMDBClientError {
            guard case let .httpStatus(statusCode) = error else {
                XCTFail("Expected http status error, got \(error)")
                return
            }

            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("Expected TMDBClientError, got \(error)")
        }
    }

    @MainActor
    func testSendThrowsDecodingErrorForInvalidJSON() async {
        let session = makeSession()
        let sut = TMDBClient(accessToken: "token", session: session)
        URLProtocolStub.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data("invalid".utf8)
            )
        }

        do {
            let _: ResponseStub = try await sut.send(.movieDetails(id: 1))
            XCTFail("Expected request to fail")
        } catch let error as TMDBClientError {
            guard case .decoding = error else {
                XCTFail("Expected decoding error, got \(error)")
                return
            }
        } catch {
            XCTFail("Expected TMDBClientError, got \(error)")
        }
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    private struct ResponseStub: Decodable, Equatable {
        let value: String
    }
}

private final class URLProtocolStub: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: TestError.failure)
            return
        }

        do {
            let (response, data) = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
