//
//  MovieListViewModel.swift
//  MovieExplorer
//
//  Created by ais on 06/10/26.
//

import Foundation
import Combine

final class MovieListViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var favoriteMovies: [Movie] = []
    @Published private(set) var genres: [Genre] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var showingFavorites = false
    @Published private(set) var currentPage = 1
    @Published private(set) var totalPages = 1
    @Published private(set) var isLoadingMore = false
    
    private let favoriteManager = FavoriteManager()
    private let service = MovieAPIService()
    
    var displayedMovies: [Movie] {
        if showingFavorites {
            return favoriteMovies
        } else {
            return movies
        }
    }
    
    init(movies: [Movie] = []) {
        self.movies = movies
        favoriteMovies = favoriteManager.getFavoriteMovies()
    }
    
    func fetchMovies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.fetchMovies(page: 1)
            
            movies = response.results
            currentPage = response.page
            totalPages = response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadNextPage() async {
        guard !isLoadingMore,
              !isLoading,
              !showingFavorites,
              currentPage < totalPages else {
            return
        }
        
        isLoadingMore = true
        defer {
            isLoadingMore = false
        }
        
        do {
            let nextPage = currentPage + 1
            let response = try await service.fetchMovies(page: nextPage)
            
            movies.append(contentsOf: response.results)
            currentPage = response.page
            totalPages = response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchGenres() async {
        do {
            let response = try await service.fetchGenres()
            genres = response.genres
        } catch {
            print(error)
        }
    }
    
    func handleSearch(query: String) async {
        if showingFavorites {
            searchFavoriteMovies(query: query)
        } else {
            await searchMovies(query: query)
        }
    }
    
    func searchMovies(query: String) async {
        guard !query.isEmpty else {
            await fetchMovies()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.searchMovies(query: query)
            movies = response.results
        } catch {
            print(error)
        }
        
        isLoading = false
    }
    
    func searchFavoriteMovies(query: String) {
        let savedFavorites = favoriteManager.getFavoriteMovies()
        
        favoriteMovies = query.isEmpty
        ? savedFavorites
        : savedFavorites.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
    }
    
    func refreshFavoriteMovies() {
        favoriteMovies = favoriteManager.getFavoriteMovies()
    }
    
    func toggleFavorites() {
        showingFavorites.toggle()

        if showingFavorites {
            refreshFavoriteMovies()
        }
    }
    
    var canShowScrollToTopButton: Bool {
        guard !displayedMovies.isEmpty else {
            return false
        }
        
        if showingFavorites {
            return displayedMovies.count >= 10
        }
        
        return currentPage > 1
    }
}
