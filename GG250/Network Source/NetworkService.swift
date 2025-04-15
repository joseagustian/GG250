//
//  NetworkService.swift
//  GG250
//
//  Created by Jose Agustian on 06/04/25.
//

import Foundation

class NetworkService {
    
    // MARK: - API Configuration
    let apiKey = "8735489a0e454493856e64c118b0e8f8"
    let pageSize = 25

    // MARK: - Fetch Games
    func getGames(page: Int) async throws -> [Games] {
        var components = URLComponents(string: "https://rawg.io/api/games/lists/popular")!
        components.queryItems = [
            URLQueryItem(name: "discover", value: "true"),
            URLQueryItem(name: "page_size", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        let request = URLRequest(url: components.url!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error: Can't fetch data.")
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(GamesResponses.self, from: data)
        
        return gameMapper(input: result.results ?? [])
    }
    
    func getGameDetail(id: Int) async throws -> GameDetail {
            var components = URLComponents(string: "https://api.rawg.io/api/games/\(id)")!
            components.queryItems = [
                URLQueryItem(name: "key", value: apiKey)
            ]
            
            let request = URLRequest(url: components.url!)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("Error: Can't fetch game detail.")
            }
            
            let decoder = JSONDecoder()
            let game = try decoder.decode(GameDetailResponses.self, from: data)
            
            return gameDetailMapper(input: game)
        }
}

// MARK: - Mapping Function
extension NetworkService {
    fileprivate func gameMapper(input responses: [Result]) -> [Games] {
        return responses.map { response in
            let gameId = response.id ?? 0
            let rating = response.rating ?? 0.0
            let gamePosterPath = response.backgroundImage ?? "https://via.placeholder.com/350x150"
            
            var formattedReleaseDate = "Unknown"
            if let released = response.released {
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd"
                
                if let date = inputFormatter.date(from: released) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "dd MMMM yyyy"
                    formattedReleaseDate = "Released on \(outputFormatter.string(from: date))"
                }
            }
            
            return Games(
                gameId: gameId,
                title: response.name ?? "Unknown",
                rating: rating,
                releaseDate: formattedReleaseDate,
                gamePosterPath: URL(string: gamePosterPath)!
            )
        }
    }
    
    fileprivate func gameDetailMapper(input response: GameDetailResponses) -> GameDetail {
        let id = response.id ?? 0
        let title = response.name ?? "Unknown"
        let rating = response.rating ?? 0.0
        let releaseDate = response.released ?? "Unknown"
        let gamePosterURLString = response.backgroundImage ?? "https://via.placeholder.com/350x150"
        let gamePosterURL = URL(string: gamePosterURLString)!
        let gameMetaScore = response.metacritic ?? 0
        let gameRatingDescription = response.ratings?.first?.title ?? "No rating info"

        let gameDescription = response.descriptionRaw ?? "No description available."

        return GameDetail(
            id: id,
            title: title,
            rating: rating,
            releaseDate: releaseDate,
            gamePosterPath: gamePosterURL,
            gameMetascore: gameMetaScore,
            gameRatingDescription: gameRatingDescription,
            gameDescription: gameDescription
        )
    }
}
