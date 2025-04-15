//
//  ViewController.swift
//  GG250
//
//  Created by Jose Agustian on 06/04/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gamesTableView: UITableView!
    
    private var games: [Games] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gamesTableView.dataSource = self
        gamesTableView.delegate = self
     
        gamesTableView.register(
          UINib(nibName: "GameTableViewCell", bundle: nil),
          forCellReuseIdentifier: "gameTableViewCell"
        )
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      Task { await getGames() }
    }
   
    func getGames() async {
      let network = NetworkService()
      do {
        games = try await network.getGames(page: 1)
        gamesTableView.reloadData()
      } catch {
        print("Error: \(error)")
        fatalError(error.localizedDescription)
      }
    }

}

extension ViewController: UITableViewDataSource {
 
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
      return games.count
  }
 
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(
      withIdentifier: "gameTableViewCell",
      for: indexPath
    ) as? GameTableViewCell {
      
      let game = games[indexPath.row]
      cell.gameTitle.text = game.title
      cell.gameImage.image = game.image
      cell.gameReleaseDate.text = game.releaseDate
      cell.gameRating.text = "\(game.rating)/5"
      
 
      if game.state == .new {
        cell.gameImageIndicatorLoading.isHidden = false
        cell.gameImageIndicatorLoading.startAnimating()
        startDownload(game: game, indexPath: indexPath)
      } else {
        cell.gameImageIndicatorLoading.stopAnimating()
        cell.gameImageIndicatorLoading.isHidden = true
      }
 
      return cell
    } else {
      return UITableViewCell()
    }
  }
 
  fileprivate func startDownload(game: Games, indexPath: IndexPath) {
    let imageDownloader = ImageDownloader()
    if game.state == .new {
      Task {
        do {
          let image = try await imageDownloader.downloadImage(url: game.gamePosterPath)
          game.state = .downloaded
          game.image = image
          self.gamesTableView.reloadRows(at: [indexPath], with: .automatic)
        } catch {
          game.state = .failed
          game.image = nil
        }
      }
    }
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    performSegue(
        withIdentifier: "moveToGameDetail",
        sender: games[indexPath.row]
    )
  }
    
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "moveToGameDetail",
        let gameDetailViewController = segue.destination as? GameDetailViewController,
        let selectedGame = sender as? Games {
         gameDetailViewController.gameId = selectedGame.gameId
     }
  }
}
