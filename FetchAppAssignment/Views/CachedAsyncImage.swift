//
//  CachedAsyncImage.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: (AsyncImagePhase) -> Content
    @State private var phase: AsyncImagePhase = .empty
    
    var body: some View {
        content(phase)
            .task(id: url) {
                await loadImage()
            }
    }
    
    private func loadImage() async {
        guard let url = url else {
            phase = .empty
            return
        }
        
        let urlString = url.absoluteString
        
        do {
            // Try to load from cache first
            if let imageData = try? await ImageCache.shared.retrieve(for: urlString),
               let uiImage = UIImage(data: imageData) {
                phase = .success(Image(uiImage: uiImage))
                return
            }
            
            // If not in cache, download and cache
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                try await ImageCache.shared.store(data, for: urlString)
                phase = .success(Image(uiImage: uiImage))
            } else {
                phase = .failure(ImageError.invalidData)
            }
        } catch {
            phase = .failure(error)
        }
    }
}
