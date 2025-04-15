//
//  FavoriteGameDetailViewController.swift
//  GG250
//
//  Created by Jose Agustian on 10/04/25.
//

import UIKit

class FavoriteGameDetailViewController: UIViewController {
    
    private lazy var favoriteGameProvider: FavoriteGameProvider = { return FavoriteGameProvider() }()

    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var gameRatingDescription: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameMetascore: UILabel!
    @IBOutlet weak var gameTitle: UILabel!
    
    private var isFavorite = false
    
    private var game: FavoriteGameModel?
    var gameId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      loadFavoriteGame()
    }
    
    private func loadFavoriteGame() {
        self.favoriteGameProvider.getFavoritedGame(gameId ?? 0) { result in
            DispatchQueue.main.async {
                self.game = result
                self.updateUI()
            }
        }
    }

    @IBAction func favorited(_ sender: Any) {
        setFavoriteButton(state: false)
        setAsUnfavorite()
    }
    
    private func setFavoriteButton(state: Bool) {
        favoriteButton.setImage(
            UIImage(
                systemName: state ? "heart.fill" : "heart"
            ), for: .normal)
    }
    
    private func setAsUnfavorite() {
        guard let gameId = game?.id else { return }

        favoriteGameProvider.removeFavoriteGame(Int32(gameId)) {
            DispatchQueue.main.async {
              let alert = UIAlertController(title: "Successful", message: "Game has unfavorited.", preferredStyle: .alert)

              alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
              })
              self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func checkIsFavorited() {
        guard let gameId = game?.id else { return }
        favoriteGameProvider.getFavoritedGame(Int(gameId)) { game in
            DispatchQueue.main.async {
                let isFavorited = game.favorite ?? false
                self.isFavorite = isFavorited
                self.setFavoriteButton(state: isFavorited)
            }
        }
    }
    
    func alert(_ message: String) {
        let allertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        allertController.addAction(alertAction)
        self.present(allertController, animated: true, completion: nil)
    }
    
    private func updateUI() {
        guard let game = game else { return }

        gameTitle.text = ""
        gameMetascore.text = ""
        gameRatingDescription.text = ""
        gameDescription.text = ""

        gameImage.image = UIImage(named: "placeholder")

        initSetUI(for: game)
        checkIsFavorited()
    }
    
    fileprivate func initSetUI(for game: FavoriteGameModel) {
        let imageDownloader = ImageDownloader()
        guard let gamePosterPath = game.gamePosterPath else { return }
        Task {
            DispatchQueue.main.async {
                self.imageLoadingIndicator.isHidden = false
                self.imageLoadingIndicator.startAnimating()
            }

            do {
                let image = try await imageDownloader.downloadImage(
                    url: gamePosterPath
                )
                DispatchQueue.main.async {
                    self.gameTitle.text = " \(game.title ?? "Failed to get title")"
                    self.gameMetascore.text = "\(game.gameMetascore ?? 0)"
                    self.gameRatingDescription.text = game.gameRatingDescription?.capitalized
                    self.gameDescription.text = game.gameDescription
                    
                    self.imageLoadingIndicator.stopAnimating()
                    self.imageLoadingIndicator.isHidden = true
                    self.gameImage.image = image
                }
            } catch {
                DispatchQueue.main.async {
                    self.gameTitle.text = " \(game.title ?? "Failed to get title")"
                    self.gameMetascore.text = "\(game.gameMetascore ?? 0)"
                    self.gameRatingDescription.text = game.gameRatingDescription
                    self.gameDescription.text = game.gameDescription
                }
            }
        }
    }
}
