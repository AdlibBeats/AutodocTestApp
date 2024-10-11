//
//  UIImageViewExtensions.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 09.10.2024.
//

import UIKit

extension UIImageView {
    enum ImageLoadingError: Error {
        case invalidData
    }

    func setImage(_ imageUrl: URL, with imageCache: NSCache<NSString, UIImage>, animate: Bool = true) {
        Task {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            guard let image = UIImage(data: data) else {
                throw ImageLoadingError.invalidData
            }
            imageCache.setObject(image, forKey: imageUrl.absoluteString as NSString)
            self.image = image

            if animate {
                alpha = 0.0
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1.0
                }
            }
        }
    }

    func makeImageLoadingTask(_ imageUrl: URL, with imageCache: NSCache<NSString, UIImage>, animate: Bool = true) -> Task<Void, Error> {
        return Task {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            guard let image = UIImage(data: data) else {
                throw ImageLoadingError.invalidData
            }
            imageCache.setObject(image, forKey: imageUrl.absoluteString as NSString)
            self.image = image

            if animate {
                alpha = 0.0
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1.0
                }
            }
        }
    }
}
