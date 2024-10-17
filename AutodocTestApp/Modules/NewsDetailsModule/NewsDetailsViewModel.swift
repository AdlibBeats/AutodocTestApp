//
//  NewsDetailsViewModel.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

protocol NewsDetailsViewModelProtocol: AnyObject {
    var newsItem: NewsEntity.NewsItem { get }
}

final class NewsDetailsViewModel: NewsDetailsViewModelProtocol {
    let newsItem: NewsEntity.NewsItem

    init(newsItem: NewsEntity.NewsItem) {
        self.newsItem = newsItem
    }
}
