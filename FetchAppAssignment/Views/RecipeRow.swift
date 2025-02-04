//
//  RecipeRow.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(.headline)
            
            Text(recipe.cuisine)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let photoUrlSmall = recipe.photoUrlSmall {
                CachedAsyncImage(url: URL(string: photoUrlSmall)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
