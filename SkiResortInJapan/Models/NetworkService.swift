//
//  NetworkService.swift
//  SkiResortInJapan
//
//  Created by Adam Chen on 2024/11/14.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchSkiResorts() async throws -> [SkiResort] {
        let urlStr = "https://raw.githubusercontent.com/ggisfun/SkiResortJapan/main/SkiResortJapan.json"
        
        guard let url = URL(string: urlStr) else {
            throw URLError(.badURL)
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([SkiResort].self, from: data)
    }
}
