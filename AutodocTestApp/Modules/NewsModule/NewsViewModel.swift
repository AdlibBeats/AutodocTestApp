//
//  NewsViewModel.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import Combine

protocol NewsViewModelProtocol: AnyObject {
    var selection: NewsEntity.NewsItem? { get set }
    var currentPage: Int { get set }

    var state: CurrentValueSubject<NewsViewModel.NewsState, Never> { get }
}

final class NewsViewModel: NewsViewModelProtocol {
    private let networkService: NetworkServiceProtocol
    private let router: NewsRouterProtocol

    @Published var selection: NewsEntity.NewsItem?
    @Published var currentPage = 1

    let state = CurrentValueSubject<NewsState, Never>(.loading)

    init(
        router: NewsRouterProtocol,
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.networkService = networkService
        self.router = router

        $selection
            .compactMap { $0 }
            .sink(receiveValue: router.showNewsDetails)
            .store(in: &subscriptions)

        $currentPage
            .mapAsyncThrows { [networkService] in
                try await networkService.fetchNews(from: $0)
            }
            .scan([]) { $0 + $1 }
            .map { .success($0) }
            .catch { Just(.failure($0)) }
            .removeDuplicates()
            .sink(receiveValue: state.send)
            .store(in: &subscriptions)
    }

    private var subscriptions = Set<AnyCancellable>()
}

extension NewsViewModel {
    enum NewsState {
        case loading
        case success([NewsEntity.NewsItem])
        case failure(Error)
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
