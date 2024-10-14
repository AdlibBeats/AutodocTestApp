//
//  NetworkService.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 14.10.2024.
//

import Foundation

protocol NetworkServiceProtocol: AnyActor {
    func fetchNews(from page: Int) async throws -> [NewsEntity.NewsItem]
}

actor NetworkService {
    private let baseUrlString = "https://webapi.autodoc.ru/api"
}

extension NetworkService: NetworkServiceProtocol {
    func fetchNews(from page: Int) async throws -> [NewsEntity.NewsItem] {
        let maxCount = 15
        guard let url = URL(string: [baseUrlString, "/news", "/\(page)", "/\(maxCount)"].joined()) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let model = try JSONDecoder().decode(NewsEntity.self, from: data)
        return model.news
    }
}
