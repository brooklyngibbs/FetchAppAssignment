//
//  RecipeViewModel.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    @Published private(set) var recipes: [Recipe] = []
    @Published private(set) var error: RecipeError? = nil  // explicitly initialize as optional
    @Published private(set) var isLoading = false
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func fetchRecipes() async {
        isLoading = true
        error = nil
        
        do {
            recipes = try await networkService.fetchRecipes()
        } catch {
            // Handle the error more explicitly
            if let recipeError = error as? RecipeError {
                self.error = recipeError
            } else {
                self.error = .networkError(error)
            }
        }
        
        isLoading = false
    }
}
