//
//  ContentView.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading recipes...")
                } else if let error = viewModel.error {
                    ErrorView(message: error.userMessage) {
                        Task {
                            await viewModel.fetchRecipes()
                        }
                    }
                } else {
                    recipeList
                }
            }
            .navigationTitle("Recipes")
            .task {
                await viewModel.fetchRecipes()
            }
        }
    }
    
    private var recipeList: some View {
        List(viewModel.recipes) { recipe in
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.headline)
                
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let photoUrlSmall = recipe.photoUrlSmall {
                    AsyncImage(url: URL(string: photoUrlSmall)) { phase in
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
        .refreshable {
            await viewModel.fetchRecipes()
        }
    }
}

#Preview {
    ContentView()
}
