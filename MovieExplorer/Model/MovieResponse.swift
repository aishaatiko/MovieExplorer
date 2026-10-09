//
//  MovieResponse.swift
//  MovieExplorer
//
//  Created by ais on 06/10/26.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}
