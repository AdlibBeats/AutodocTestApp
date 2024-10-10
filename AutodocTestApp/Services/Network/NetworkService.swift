//
//  NetworkService.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 09.10.2024.
//

import Foundation

protocol NewsFetcher: AnyObject {
    func fetchNews(from page: Int) async throws -> NewsModel
}

final class NetworkService {
    enum NetworkServiceError: Error {
        case invalidURL
        case missingData
    }

    private let baseUrl = "https://webapi.autodoc.ru/api"

    private let urlSession: URLSession

    init(configuration: URLSessionConfiguration = .default) {
        urlSession = .init(configuration: configuration)
    }
}

extension NetworkService: NewsFetcher {
    func fetchNews(from page: Int) async throws -> NewsModel {
        let maxCount = 15
        guard let url = URL(string: [baseUrl, "/news", "/\(page)", "/\(maxCount)"].joined()) else {
            throw NetworkServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(NewsModel.self, from: data)
    }
}
