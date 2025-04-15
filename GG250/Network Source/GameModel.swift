//
//  GameModel.swift
//  GG250
//
//  Created by Jose Agustian on 06/04/25.
//
import Foundation
import UIKit

enum DownloadState {
  case new, downloaded, failed
}

class Games {
    let gameId: Int
    let title: String
    let rating: Double
    let releaseDate: String
    let gamePosterPath: URL
    
    var image: UIImage?
    var state: DownloadState = .new
    
    init(
        gameId: Int,
        title: String,
        rating: Double,
        releaseDate: String,
        gamePosterPath: URL
    ) {
        self.gameId = gameId
        self.title = title
        self.rating = rating
        self.releaseDate = releaseDate
        self.gamePosterPath = gamePosterPath
    }
}

/// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let game = try? JSONDecoder().decode(Game.self, from: jsonData)
// MARK: - Game
struct GamesResponses: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [Result]?
}

// MARK: - Result
struct Result: Codable {
    let id: Int?
    let slug, name, released: String?
    let tba: Bool?
    let backgroundImage: String?
    let rating: Double?
    let ratingTop: Int?
    let ratings: [Rating]?
    let ratingsCount, reviewsTextCount, added: Int?
    let addedByStatus: AddedByStatus?
    let metacritic, playtime, suggestionsCount: Int?
    let updated: String?
    let userGame: JSONNull?
    let reviewsCount: Int?
    let saturatedColor, dominantColor: String?
    let platforms: [PlatformElement]?
    let parentPlatforms: [ParentPlatform]?
    let genres: [Genre]?
    let stores: [Store]?
    let clip: Clip?
    let tags: [Genre]?
    let esrbRating: EsrbRating?
    let shortScreenshots: [ShortScreenshot]?

    enum CodingKeys: String, CodingKey {
        case id, slug, name, released, tba
        case backgroundImage = "background_image"
        case rating
        case ratingTop = "rating_top"
        case ratings
        case ratingsCount = "ratings_count"
        case reviewsTextCount = "reviews_text_count"
        case added
        case addedByStatus = "added_by_status"
        case metacritic, playtime
        case suggestionsCount = "suggestions_count"
        case updated
        case userGame = "user_game"
        case reviewsCount = "reviews_count"
        case saturatedColor = "saturated_color"
        case dominantColor = "dominant_color"
        case platforms
        case parentPlatforms = "parent_platforms"
        case genres, stores, clip, tags
        case esrbRating = "esrb_rating"
        case shortScreenshots = "short_screenshots"
    }
}

// MARK: - AddedByStatus
struct AddedByStatus: Codable {
    let yet, owned, beaten, toplay: Int?
    let dropped, playing: Int?
}

// MARK: - Clip
struct Clip: Codable {
    let clip: String?
    let clips: Clips?
    let video: String?
    let preview: String?
}

// MARK: - Clips
struct Clips: Codable {
    let the320, the640, full: String?

    enum CodingKeys: String, CodingKey {
        case the320 = "320"
        case the640 = "640"
        case full
    }
}

// MARK: - EsrbRating
struct EsrbRating: Codable {
    let id: Int?
    let name, slug: String?
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?
    let domain: String?
    let language: Language?

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case gamesCount = "games_count"
        case imageBackground = "image_background"
        case domain, language
    }
}

enum Language: String, Codable {
    case eng = "eng"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        self = Language(rawValue: rawValue ?? "") ?? .unknown
    }
}

// MARK: - ParentPlatform
struct ParentPlatform: Codable {
    let platform: EsrbRating?
}

// MARK: - PlatformElement
struct PlatformElement: Codable {
    let platform: PlatformPlatform?
    let releasedAt: String?
    let requirementsEn: Requirements?
    let requirementsRu: Requirements?

    enum CodingKeys: String, CodingKey {
        case platform
        case releasedAt = "released_at"
        case requirementsEn = "requirements_en"
        case requirementsRu = "requirements_ru"
    }
}

// MARK: - PlatformPlatform
struct PlatformPlatform: Codable {
    let id: Int?
    let name, slug: String?
    let image, yearEnd: JSONNull?
    let yearStart: Int?
    let gamesCount: Int?
    let imageBackground: String?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, image
        case yearEnd = "year_end"
        case yearStart = "year_start"
        case gamesCount = "games_count"
        case imageBackground = "image_background"
    }
}

// MARK: - Requirements
struct Requirements: Codable {
    let minimum, recommended: String?
}

// MARK: - Rating
struct Rating: Codable {
    let id: Int?
    let title: String?
    let count: Int?
    let percent: Double?
}

// MARK: - ShortScreenshot
struct ShortScreenshot: Codable {
    let id: Int?
    let image: String?
}

// MARK: - Store
struct Store: Codable {
    let id: Int?
    let store: Genre?
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(
                JSONNull.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Wrong type for JSONNull"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
