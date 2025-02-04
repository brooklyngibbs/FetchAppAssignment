//
//  Recipe.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

struct RecipeResponse: Decodable {
    let recipes: [Recipe]
}

struct Recipe: Identifiable, Decodable {
    let uuid: String
    let name: String
    let cuisine: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let sourceUrl: String?
    let youtubeUrl: String?
    
    var id: String { uuid }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case cuisine
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }
}

