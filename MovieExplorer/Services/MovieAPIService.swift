//
//  MovieAPIService.swift
//  MovieExplorer
//
//  Created by ais on 06/10/26.
//

import Foundation

struct MovieAPIService {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "API_KEY"
    
    func fetchMovies(page: Int = 1) async throws -> MovieResponse {
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(MovieResponse.self, from: data)
    }
    
    func fetchGenres() async throws -> GenreResponse {
        let urlString = "\(baseURL)/genre/movie/list?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GenreResponse.self, from: data)
    }
    
    func searchMovies(query: String) async throws -> MovieResponse {
        var components = URLComponents(
            string: "\(baseURL)/search/movie"
        )!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(MovieResponse.self, from: data)
    }
}
