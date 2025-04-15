//
//  GameTableViewCell.swift
//  GG250
//
//  Created by Jose Agustian on 06/04/25.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameReleaseDate: UILabel!
    @IBOutlet weak var gameRating: UILabel!
    @IBOutlet weak var gameImageIndicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var gameImage: UIImageView!
    
    private var isFavorite = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func startLoading() {
        gameImageIndicatorLoading.startAnimating()
        }

    func stopLoading() {
        gameImageIndicatorLoading.stopAnimating()
    }
}
