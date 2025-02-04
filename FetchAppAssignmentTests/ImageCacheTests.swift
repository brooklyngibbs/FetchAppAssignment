//
//  ImageCacheTests.swift
//  FetchAppAssignmentTests
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI
import XCTest

@testable import FetchAppAssignment

class ImageCacheTests: XCTestCase {
    var imageCache: ImageCache!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        imageCache = ImageCache.shared
    }
    
    override func tearDownWithError() throws {
        // Need to handle async teardown differently
        let expectation = expectation(description: "Cache cleared")
        
        Task {
            try await imageCache.clearCache()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        try super.tearDownWithError()
    }
    
    func testStoreAndRetrieveImage() async throws {
        // Given
        let testData = "test".data(using: .utf8)!
        let key = "test-image"
        
        // When
        try await imageCache.store(testData, for: key)
        let retrievedData = try await imageCache.retrieve(for: key)
        
        // Then
        XCTAssertEqual(testData, retrievedData)
    }
    
    func testClearCache() async throws {
        // Given
        let testData = "test".data(using: .utf8)!
        let key = "test-image"
        
        // When
        try await imageCache.store(testData, for: key)
        try await imageCache.clearCache()
        
        // Then
        do {
            _ = try await imageCache.retrieve(for: key)
            XCTFail("Expected error not thrown")
        } catch {
            // Success - file should not exist
        }
    }
}
