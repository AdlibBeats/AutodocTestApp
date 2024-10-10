//
//  UIImageViewExtensions.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 09.10.2024.
//

import UIKit

private let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    enum ImageLoaderError: Error {
        case invalidData
    }

    func setImage(url: URL, placeholder: UIImage?) {
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as NSString) {
            self.image = imageFromCache
        } else {
            self.image = placeholder
            Task {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    throw ImageLoaderError.invalidData
                }
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                self.image = image
            }
        }
    }
}
