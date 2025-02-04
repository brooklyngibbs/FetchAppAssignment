//
//  RecipeError.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

enum RecipeError: Error, Equatable {
    case invalidData
    case networkError(Error)
    case decodingError(Error)
    case emptyResponse
    
    var userMessage: String {
        switch self {
        case .invalidData:
            return "The recipe data appears to be invalid. Please try again later."
        case .networkError:
            return "Unable to load recipes. Please check your internet connection."
        case .decodingError:
            return "There was a problem processing the recipe data."
        case .emptyResponse:
            return "No recipes available at the moment."
        }
    }
    
    // Add custom Equatable implementation because Error doesn't conform to Equatable
    static func == (lhs: RecipeError, rhs: RecipeError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidData, .invalidData):
            return true
        case (.emptyResponse, .emptyResponse):
            return true
        case (.networkError, .networkError):
            return true  // Compare only the case, not the associated value
        case (.decodingError, .decodingError):
            return true  // Compare only the case, not the associated value
        default:
            return false
        }
    }
}
