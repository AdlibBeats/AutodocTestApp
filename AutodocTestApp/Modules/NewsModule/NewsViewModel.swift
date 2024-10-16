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
    private let networkService: NetworkServiceProtocol
    private let router: NewsRouterProtocol

    init(
        router: NewsRouterProtocol,
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.networkService = networkService
        self.router = router
    }

    private var subscriptions = Set<AnyCancellable>()
}

extension NewsViewModel: NewsViewModelProtocol {
    func transform(_ input: Input) -> Output {
        let initialState = Just(NewsState.loading).eraseToAnyPublisher()
        let newsItems = PassthroughSubject<NewsState, Never>()

        input.selection.bind(to: router.showNewsDetails).store(in: &subscriptions)
        input.currentPage
            .mapAsyncThrows { [networkService] in
                try await networkService.fetchNews(from: $0)
            }
            .scan([]) { $0 + $1 }
            .map { .success($0) }
            .catch { Just(NewsState.failure($0)) }
            .sink(receiveValue: newsItems.send)
            .store(in: &subscriptions)

        return Output(state: Publishers.Merge(initialState, newsItems).removeDuplicates().eraseToAnyPublisher())
    }
}

extension NewsViewModel {
    enum NewsState {
        case loading
        case success([NewsEntity.NewsItem])
        case failure(Error)
    }

    struct Input {
        let selection: PassthroughSubject<NewsEntity.NewsItem, Never>
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
        case (.failure, .failure): return true
        default: return false
        }
    }
}
