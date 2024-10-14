//
//  NewsDetailsViewModel.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import Foundation

import Combine

protocol NewsDetailsViewModelProtocol: AnyObject {
    typealias Input = NewsDetailsViewModel.Input
    typealias Output = NewsDetailsViewModel.Output

    func transform(_ input: Input) -> Output
}

final class NewsDetailsViewModel {
    private let newsItem: NewsEntity.NewsItem

    init(newsItem: NewsEntity.NewsItem) {
        self.newsItem = newsItem
    }

    private var subscriptions = Set<AnyCancellable>()
}

extension NewsDetailsViewModel {
    enum NewsState {
        case render(NewsEntity.NewsItem)
    }

    struct Input {

    }

    struct Output {
        let state: AnyPublisher<NewsState, Never>
    }
}

extension NewsDetailsViewModel: NewsDetailsViewModelProtocol {
    func transform(_ input: Input) -> Output {
        .init(state: Just(.render(newsItem)).eraseToAnyPublisher())
    }
}
