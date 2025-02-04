//
//  ContentView.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecipeViewModel()
    @State private var animationAmount = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cool gradient background
                LinearGradient(
                    colors: [.teal.opacity(0.2), .purple.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(animationAmount)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        animationAmount = 0.5
                    }
                }
                
                Group {
                    if viewModel.isLoading {
                        loadingView
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
            }
            .navigationTitle("Discover Recipes 🍳")
            .task {
                await viewModel.fetchRecipes()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.teal)
            Text("Cooking up something good...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var recipeList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.recipes) { recipe in
                    RecipeCard(recipe: recipe)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .refreshable {
            await viewModel.fetchRecipes()
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let photoUrlSmall = recipe.photoUrlSmall {
                AsyncImage(url: URL(string: photoUrlSmall)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                ProgressView()
                                    .tint(.teal)
                            }
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    case .failure:
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                            }
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.teal, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(recipe.cuisine)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(
            color: .black.opacity(0.1),
            radius: isPressed ? 15 : 10,
            x: 0,
            y: isPressed ? 5 : 2
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isPressed = false
                    }
                }
            }
        }
    }
}
