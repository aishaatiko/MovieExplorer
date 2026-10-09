//
//  GenreResponse.swift
//  MovieExplorer
//
//  Created by ais on 08/10/26.
//

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}
