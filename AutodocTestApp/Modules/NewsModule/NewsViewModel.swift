//
//  NewsViewModel.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import Combine

protocol NewsViewModelProtocol: AnyObject {
    typealias Input = NewsViewModel.Input
    typealias Output = NewsViewModel.Output

    func transform(_ input: Input) -> Output
}

final class NewsViewModel {
    private let fetcher: NewsFetcher
    private let router: NewsRouterProtocol

    init(router: NewsRouterProtocol, fetcher: NewsFetcher = NetworkService()) {
        self.router = router
        self.fetcher = fetcher
    }

    private var subscriptions = Set<AnyCancellable>()
}

extension NewsViewModel: NewsViewModelProtocol {
    func transform(_ input: Input) -> Output {
        let initialState = Just(NewsState.loading).eraseToAnyPublisher()
        let newsItems = PassthroughSubject<NewsState, Never>()

        input.selection
            .sink(receiveValue: { [router] value in
                router.showNewsDetails.send(value)
            }).store(in: &subscriptions)
        input.currentPage.sink(receiveValue: { [fetcher] value in
            Task {
                do {
                    newsItems.send(.success(try await fetcher.fetchNews(from: value).news))
                } catch {
                    newsItems.send(.failure(error))
                }
            }
        }).store(in: &subscriptions)

        let output = Output(state: Publishers.Merge(initialState, newsItems).removeDuplicates().eraseToAnyPublisher())

        return output
    }
}

extension NewsViewModel {
    enum NewsState {
        case loading
        case success([NewsModel.NewsItem])
        case noResults
        case failure(Error)
    }

    struct Input {
        let selection: PassthroughSubject<NewsModel.NewsItem, Never>
        let currentPage: CurrentValueSubject<Int, Never>
    }

    struct Output {
        let state: AnyPublisher<NewsState, Never>
    }
}

extension NewsViewModel.NewsState: Equatable {
    static func == (lhs: NewsViewModel.NewsState, rhs: NewsViewModel.NewsState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.success(let lhsNews), .success(let rhsNews)): return lhsNews == rhsNews
        case (.noResults, .noResults): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}
