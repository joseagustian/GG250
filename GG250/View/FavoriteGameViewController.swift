//
//  FavoriteGameViewController.swift
//  GG250
//
//  Created by Jose Agustian on 10/04/25.
//

import UIKit

class FavoriteGameViewController: UIViewController {

    @IBOutlet weak var favoriteGamesTableView: UITableView!
    
    private var favoriteGames: [FavoriteGameModel] = []
    private lazy var favoriteGameProvider: FavoriteGameProvider = { return FavoriteGameProvider() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteGamesTableView.dataSource = self
        favoriteGamesTableView.delegate = self
     
        favoriteGamesTableView.register(
          UINib(nibName: "GameTableViewCell", bundle: nil),
          forCellReuseIdentifier: "gameTableViewCell"
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        loadFavoriteGames()
    }
    
    private func loadFavoriteGames() {
        self.favoriteGameProvider.getAllFavorite { result in
              DispatchQueue.main.async {
                self.favoriteGames = result
                self.favoriteGamesTableView.reloadData()
              }
        }
    }
}

extension FavoriteGameViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favoriteGames.count
  }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if let cell = tableView.dequeueReusableCell(withIdentifier: "gameTableViewCell", for: indexPath) as? GameTableViewCell {
          let favoriteGame = favoriteGames[indexPath.row]
              
          if let imageUrl = favoriteGame.gamePosterPath {
                 cell.startLoading()
                 URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                     guard let data = data, error == nil else { return }
                     DispatchQueue.main.async {
                         cell.gameImage.image = UIImage(data: data)
                         cell.stopLoading()
                     }
                 }.resume()
          } else {
              cell.gameImage.image = UIImage(named: "placeholder")
              cell.stopLoading()
          }
              
          cell.gameTitle.text = favoriteGame.title
          cell.gameReleaseDate.text = favoriteGame.releaseDate
          cell.gameRating.text = "\(favoriteGame.rating ?? 0.0)/5"
              
          return cell
        } else {
          return UITableViewCell()
        }
      }
}

extension FavoriteGameViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: "moveToFavoriteDetail",
            sender: favoriteGames[indexPath.row]
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToFavoriteDetail",
           let gameDetailViewController = segue.destination as? FavoriteGameDetailViewController,
           let selectedGame = sender as? FavoriteGameModel {
            gameDetailViewController.gameId = Int(selectedGame.id ?? 0)
        }
    }
}
