//
//  ImageLoaderService.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 14.10.2024.
//

import Foundation

import class UIKit.UIImage

protocol ImageLoaderServiceProtocol: AnyActor {
    func loadImage(by url: URL) async throws -> UIImage
}

actor ImageLoaderService {
    private var cache = NSCache<NSString, UIImage>()
}

extension ImageLoaderService: ImageLoaderServiceProtocol {
    func loadImage(by url: URL) async throws -> UIImage {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            return image
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        cache.setObject(image, forKey: url.absoluteString as NSString)

        return image
    }
}
