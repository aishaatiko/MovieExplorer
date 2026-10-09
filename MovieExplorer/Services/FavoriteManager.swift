//
//  FavoriteManager.swift
//  MovieExplorer
//
//  Created by ais on 08/10/26.
//

import Foundation

final class FavoriteManager {
    private let key = "favoriteMovies"

    private let defaults = UserDefaults.standard

    func getFavoriteMovies() -> [Movie] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }

        return (try? JSONDecoder().decode([Movie].self, from: data)) ?? []
    }

    func isFavorite(movieID: Int) -> Bool {
        getFavoriteMovies().contains { $0.id == movieID }
    }

    func addFavorite(movie: Movie) {
        var movies = getFavoriteMovies()

        guard !movies.contains(where: { $0.id == movie.id }) else {
            return
        }

        movies.append(movie)
        saveFavoriteMovies(movies)
    }

    func removeFavorite(movieID: Int) {
        var movies = getFavoriteMovies()
        movies.removeAll { $0.id == movieID }
        saveFavoriteMovies(movies)
    }

    func toggleFavorite(movie: Movie) {
        if isFavorite(movieID: movie.id) {
            removeFavorite(movieID: movie.id)
        } else {
            addFavorite(movie: movie)
        }
    }

    private func saveFavoriteMovies(_ movies: [Movie]) {
        guard let data = try? JSONEncoder().encode(movies) else {
            return
        }

        defaults.set(data, forKey: key)
    }
}
