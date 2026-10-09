//
//  MovieListView.swift
//  MovieExplorer
//
//  Created by ais on 06/10/26.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel: MovieListViewModel
    @State private var searchText = ""
    private let shouldFetch: Bool
    @State private var isScrolledDown = false
    
    init(
        viewModel: MovieListViewModel = MovieListViewModel(),
        shouldFetch: Bool = true
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.shouldFetch = shouldFetch
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Group {
                    if viewModel.isLoading && viewModel.movies.isEmpty {
                        ProgressView("Loading movies...")
                    } else if let errorMessage = viewModel.errorMessage,
                              viewModel.movies.isEmpty {
                        VStack(spacing: 12) {
                            Text("Something went wrong")
                                .font(.headline)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Try Again") {
                                Task {
                                    await viewModel.fetchMovies()
                                }
                            }
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(viewModel.displayedMovies) { movie in
                                NavigationLink {
                                    MovieDetailView(
                                        movie: movie,
                                        genres: viewModel.genres
                                    )
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        if let posterURL = movie.posterURL {
                                            AsyncImage(url: posterURL) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 80, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.gray.opacity(0.3))
                                                .frame(width: 80, height: 120)
                                                .overlay {
                                                    Image(systemName: "film")
                                                        .foregroundStyle(.gray)
                                                }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(movie.title)
                                                .font(.headline)
                                            
                                            if let releaseDate = movie.formattedReleaseDate {
                                                Text(releaseDate)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            if let voteAverage = movie.voteAverage {
                                                Label(
                                                    String(format: "%.1f", voteAverage),
                                                    systemImage: "star.fill"
                                                )
                                                .font(.subheadline)
                                            }
                                            
                                            if let overview = movie.overview {
                                                Text(overview)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(3)
                                            }
                                        }
                                    }
                                }
                                .id(movie.id)
                                .onAppear {
                                    guard !viewModel.showingFavorites,
                                          searchText.isEmpty,
                                          movie.id == viewModel.movies.last?.id else {
                                        return
                                    }
                                    
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                            
                            if viewModel.isLoadingMore {
                                HStack {
                                    Spacer()
                                    ProgressView("Loading more movies...")
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    geometry.contentOffset.y > 0
                } action: { _, isScrolledDown in
                    self.isScrolledDown = isScrolledDown
                }
                .overlay(alignment: .bottom) {
                    if viewModel.canShowScrollToTopButton && isScrolledDown {
                        Button {
                            guard let firstMovie = viewModel.displayedMovies.first else {
                                return
                            }
                            
                            withAnimation {
                                proxy.scrollTo(firstMovie.id, anchor: .top)
                            }
                        } label: {
                            Image(systemName: "arrow.up")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(.blue, in: Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                viewModel.refreshFavoriteMovies()
            }
            .searchable(text: $searchText, prompt: "Search movies")
            .onChange(of: searchText) {
                Task {
                    await viewModel.handleSearch(query: searchText)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleFavorites()
                    } label: {
                        Image(systemName: viewModel.showingFavorites ? "film" : "heart")
                    }
                }
            }
            .navigationTitle(
                viewModel.showingFavorites ? "Favorites" : "Movies"
            )
        }
        .task {
            if shouldFetch {
                await viewModel.fetchMovies()
                await viewModel.fetchGenres()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MovieListView(
            viewModel: MovieListViewModel(
                movies: [
                    Movie(
                        id: 1,
                        title: "Spider-Man: Brand New Day",
                        overview: "A Spider-Man movie.",
                        posterPath: nil,
                        releaseDate: "2026-07-31",
                        voteAverage: 6.6,
                        genreIds: [123],
                    ),
                    Movie(
                        id: 2,
                        title: "Avengers: Doomsday",
                        overview: "An Avengers movie.",
                        posterPath: nil,
                        releaseDate: "2026-12-18",
                        voteAverage: 7.5,
                        genreIds: [124],
                    )
                ]
            ),
            shouldFetch: false
        )
    }
    
}
