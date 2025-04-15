//
//  FavoriteGameModel.swift
//  GG250
//
//  Created by Jose Agustian on 10/04/25.
//

import Foundation

enum FavoritDownloadState {
  case new, downloaded, failed
}

struct FavoriteGameModel {
    var id: Int32?
    var title: String?
    var rating: Double?
    var releaseDate: String?
    var gamePosterPath: URL?
    var gameMetascore: Int32?
    var gameRatingDescription: String?
    var gameDescription: String?
    var favorite: Bool?
}
