//
//  NewsEntity.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 09.10.2024.
//

import Foundation

struct NewsEntity: Decodable {
    struct NewsItem: Decodable {
        let id: Int
        let title, description, publishedDateString, url, fullUrl, titleImageUrlString, categoryType: String?

        enum CodingKeys: String, CodingKey {
            case id, title, description, url, fullUrl, categoryType
            case publishedDateString = "publishedDate"
            case titleImageUrlString = "titleImageUrl"
        }
    }

    let news: [NewsItem]
}

extension NewsEntity.NewsItem {
    var publishedDate: Date? {
        guard let publishedDateString = publishedDateString else { return nil }
        return DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }.date(from: publishedDateString)
    }

    var titleImageUrl: URL? {
        guard let titleImageUrlString = titleImageUrlString else { return nil }

        return URL(string: titleImageUrlString)
    }
}

extension NewsEntity.NewsItem: Hashable {
    static func == (
        lhs: NewsEntity.NewsItem,
        rhs: NewsEntity.NewsItem
    ) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
