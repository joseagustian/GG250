//
//  DetailGameViewController.swift
//  GG250
//
//  Created by Jose Agustian on 07/04/25.
//

import UIKit

class GameDetailViewController: UIViewController {

    private lazy var favoriteGameProvider: FavoriteGameProvider = { return FavoriteGameProvider() }()
    
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gameMetascore: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var gameRatingDescription: UILabel!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    
    private var isFavorite = false
    
    private var game: GameDetail?
    var gameId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      Task { await getGamesById(id: gameId ?? 0) }
    }
   
    @IBAction func favorited(_ sender: Any) {
        isFavorite.toggle()
        if isFavorite {
            setFavoriteButton(state: true)
            setAsFavorite()
        } else {
            setFavoriteButton(state: false)
            setAsUnfavorite()
        }
    }
    
    func getGamesById(id: Int) async {
      let network = NetworkService()
      do {
        game = try await network.getGameDetail(id: id)
        DispatchQueue.main.async {
            self.updateUI()
        }
      } catch {
        print("Error: \(error)")
        fatalError(error.localizedDescription)
      }
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
    
    private func setFavoriteButton(state: Bool) {
        favoriteButton.setImage(
            UIImage(
                systemName: state ? "heart.fill" : "heart"
            ), for: .normal)
    }
    
    private func setAsFavorite() {
        guard let gameId = game?.id else { return }
        guard let title = game?.title else { return }
        guard let rating = game?.rating else { return }
        guard let releaseDate = game?.releaseDate else { return }
        guard let gamePosterPath = game?.gamePosterPath else { return }
        guard let gameMetascore = game?.gameMetascore else { return }
        guard let gameRatingDescription = game?.gameRatingDescription else { return }
        guard let gameDescription = game?.gameDescription else { return }
        let isFavoriteGame: Bool = true

        favoriteGameProvider.setFavoriteGame(
            Int32(gameId),
            title,
            rating,
            releaseDate,
            gamePosterPath,
            Int32(gameMetascore),
            gameRatingDescription,
            gameDescription,
            isFavoriteGame
        ) {
            DispatchQueue.main.async {
              let alert = UIAlertController(title: "Successful", message: "Game has favorited.", preferredStyle: .alert)

              alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
              })
              self.present(alert, animated: true, completion: nil)
            }
        }
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
        favoriteGameProvider.getFavoritedGame(gameId) { game in
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
    
    fileprivate func initSetUI(for game: GameDetail) {
        let imageDownloader = ImageDownloader()
        Task {
            DispatchQueue.main.async {
                self.imageLoadingIndicator.isHidden = false
                self.imageLoadingIndicator.startAnimating()
            }

            do {
                let image = try await imageDownloader.downloadImage(url: game.gamePosterPath)
                DispatchQueue.main.async {
                    self.gameTitle.text = " \(game.title) "
                    self.gameMetascore.text = "\(game.gameMetascore)"
                    self.gameRatingDescription.text = game.gameRatingDescription.capitalized
                    self.gameDescription.text = game.gameDescription
                    
                    self.imageLoadingIndicator.stopAnimating()
                    self.imageLoadingIndicator.isHidden = true
                    self.gameImage.image = image
                }
            } catch {
                DispatchQueue.main.async {
                    self.gameTitle.text = " \(game.title) "
                    self.gameMetascore.text = "\(game.gameMetascore)"
                    self.gameRatingDescription.text = game.gameRatingDescription
                    self.gameDescription.text = game.gameDescription
                }
            }
        }
    }
}
