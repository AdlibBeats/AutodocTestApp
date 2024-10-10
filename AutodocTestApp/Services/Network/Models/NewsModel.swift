//
//  NewsModel.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 09.10.2024.
//

import Foundation

struct NewsModel: Decodable {
    struct NewsItem: Decodable {
        let id: Int
        let title, description, publishedDateString, url, fullUrl, titleImageUrl, categoryType: String?

        enum CodingKeys: String, CodingKey {
            case id, title, description, url, fullUrl, titleImageUrl, categoryType
            case publishedDateString = "publishedDate"
        }
    }

    let news: [NewsItem]
}

extension NewsModel.NewsItem {
    var publishedDate: Date? {
        guard let publishedDateString = publishedDateString else { return nil }
        return DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }.date(from: publishedDateString)
    }
}

extension NewsModel.NewsItem: Hashable {
    static func == (
        lhs: NewsModel.NewsItem,
        rhs: NewsModel.NewsItem
    ) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
