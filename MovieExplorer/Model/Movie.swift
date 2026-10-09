//
//  Movie.swift
//  MovieExplorer
//
//  Created by ais on 06/10/26.
//

import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let genreIds: [Int]

    var posterURL: URL? {
        guard let posterPath else {
            return nil
        }

        return URL(
            string: "https://image.tmdb.org/t/p/w500\(posterPath)"
        )
    }

    var formattedReleaseDate: String? {
        guard let releaseDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: releaseDate) else {
            return releaseDate
        }

        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}
