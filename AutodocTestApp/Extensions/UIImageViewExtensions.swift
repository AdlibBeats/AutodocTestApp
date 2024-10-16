//
//  UIImageViewExtensions.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 14.10.2024.
//

import UIKit

extension UIImageView {
    private static let imageLoader: ImageLoaderServiceProtocol = ImageLoaderService()

    @MainActor
    func setImage(by url: URL, animate: Bool = true) async throws {
        let image = try await Self.imageLoader.loadImage(by: url)

        guard !Task.isCancelled else { return }

        alpha = animate ? 0.0 : 1.0
        self.image = image
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
            }
        }
    }
}
