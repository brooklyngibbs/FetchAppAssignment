//
//  NetworkServiceTest.swift
//  FetchAppAssignmentTests
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI
import XCTest

@testable import FetchAppAssignment

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler not set")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    var urlSession: URLSession!
    
    override func setUp() {
        super.setUp()
            
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        networkService = NetworkService(session: urlSession)  // Inject the mock session
    }
    
    override func tearDown() {
        networkService = nil
        urlSession = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testSuccessfulRecipeFetch() async throws {
        // Given
        let jsonString = """
        {
            "recipes": [
                {
                    "uuid": "123",
                    "name": "Test Recipe",
                    "cuisine": "Italian",
                    "photo_url_small": "https://example.com/small.jpg"
                }
            ]
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
        
        // When
        let recipes = try await networkService.fetchRecipes()
        
        // Then
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.name, "Test Recipe")
        XCTAssertEqual(recipes.first?.cuisine, "Italian")
    }
    
    func testEmptyResponse() async {
        // Given
        let jsonString = """
        {
            "recipes": []
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
        
        // Then
        do {
            _ = try await networkService.fetchRecipes()
            XCTFail("Expected error not thrown")
        } catch let error as RecipeError {
            switch error {
            case .emptyResponse:
                // Test passed
                break
            default:
                XCTFail("Expected .emptyResponse but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
