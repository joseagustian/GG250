//
//  ImageDownloader.swift
//  GG250
//
//  Created by Jose Agustian on 06/04/25.
//

import Foundation
import UIKit

class ImageDownloader {
    func downloadImage(url: URL) async throws -> UIImage {
        async let imageData: Data = try Data(contentsOf: url)
        return UIImage(data: try await imageData)!
    }
}
