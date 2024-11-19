//
//  SkiResort.swift
//  SkiResortInJapan
//
//  Created by Adam Chen on 2024/11/14.
//

import Foundation

struct SkiResort: Codable {
    let name: String
    let description: String
    let trailCount: Int
    let liftCount: Int
    let elevation: String
    let maxSlope: Int
    let longestRun: Int
    let trailDifficulty: TrailDifficulty
    let trailComposition: TrailComposition
    let mapUrl: String
    let websiteUrl: String
    
    static func saveFavorites(_ favorites: [String]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(favorites)
            UserDefaults.standard.set(data, forKey: "favorites")
            print("Favorites saved successfully.")
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }
    
    static func loadFavorites() -> [String]? {
        guard let data = UserDefaults.standard.data(forKey: "favorites") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([String].self, from: data)
    }
}

struct TrailDifficulty: Codable {
    let beginner: Double
    let intermediate: Double
    let advanced: Double
}

struct TrailComposition: Codable {
    let groomed: Double
    let ungroomed: Double
}
