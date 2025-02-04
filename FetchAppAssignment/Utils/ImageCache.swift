//
//  ImageCache.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func cacheFileURL(for key: String) -> URL {
        cacheDirectory.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
    }
    
    func store(_ data: Data, for key: String) throws {
        let fileURL = cacheFileURL(for: key)
        try data.write(to: fileURL)
    }
    
    func retrieve(for key: String) throws -> Data {
        let fileURL = cacheFileURL(for: key)
        return try Data(contentsOf: fileURL)
    }
    
    func clearCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for file in contents {
            try fileManager.removeItem(at: file)
        }
    }
}
