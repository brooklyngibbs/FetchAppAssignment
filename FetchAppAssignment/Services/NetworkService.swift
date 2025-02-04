//
//  NetworkService.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

actor NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://d3jbb8n5wk0qxi.cloudfront.net"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: "\(baseURL)/recipes.json") else {
            throw RecipeError.invalidData
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw RecipeError.networkError(NSError(domain: "", code: -1))
            }
            
            let decoder = JSONDecoder()
            let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
            
            guard !recipeResponse.recipes.isEmpty else {
                throw RecipeError.emptyResponse
            }
            
            return recipeResponse.recipes
        } catch let error as RecipeError {
            // Don't rewrap RecipeError types
            throw error
        } catch let decodingError as DecodingError {
            throw RecipeError.decodingError(decodingError)
        } catch {
            throw RecipeError.networkError(error)
        }
    }
}
