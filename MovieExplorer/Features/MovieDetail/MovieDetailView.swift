//
//  MovieDetailView.swift
//  MovieExplorer
//
//  Created by ais on 06/10/26.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    let genres: [Genre]
    
    private var movieGenres: [Genre] {
        genres.filter { genre in
            movie.genreIds.contains(genre.id)
        }
    }
    
    @State private var isFavorite = false
    
    private let favoriteManager = FavoriteManager()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 450)
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(movie.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        if let releaseDate = movie.formattedReleaseDate {
                            Label(
                                releaseDate,
                                systemImage: "calendar"
                            )
                        }
                        
                        if let voteAverage = movie.voteAverage {
                            Label(
                                String(format: "%.1f", voteAverage),
                                systemImage: "star.fill"
                            )
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    if !movieGenres.isEmpty {
                        Text(
                            movieGenres
                                .map(\.name)
                                .joined(separator: " • ")
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    }
                }
                
                if let overview = movie.overview {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overview")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(overview)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFavorite = favoriteManager.isFavorite(movieID: movie.id)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favoriteManager.toggleFavorite(movie: movie)
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(
            movie: Movie(
                id: 969681,
                title: "Spider-Man: Brand New Day",
                overview: "Peter Parker returns for another adventure.",
                posterPath: "/bjiS5ipwxb9JFy3XRRN4OAilSeX.jpg",
                releaseDate: "2026-07-31",
                voteAverage: 8.2,
                genreIds: [123, 124, 878]
            ),
            genres: [
                Genre(id: 123, name: "Action"),
                Genre(id: 124, name: "Adventure"),
                Genre(id: 878, name: "Science Fiction")
            ]
        )
    }
    
}
