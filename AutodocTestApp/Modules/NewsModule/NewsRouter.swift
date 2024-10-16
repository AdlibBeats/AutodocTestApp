//
//  NewsRouter.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import Combine

import class UIKit.UIViewController

protocol NewsRouterProtocol: AnyObject {
    var showNewsDetails: PassthroughSubject<NewsEntity.NewsItem, Never> { get }
}

final class NewsRouter: NewsRouterProtocol {
    private var subscriptions = Set<AnyCancellable>()

    let showNewsDetails = PassthroughSubject<NewsEntity.NewsItem, Never>()

    weak var viewController: UIViewController?

    init() {
        func bind() {
            showNewsDetails
                .sink { [weak self] in
                    let newsDetailsViewModel = NewsDetailsViewModel(newsItem: $0)
                    let newsDetailsViewController = NewsDetailsViewController(viewModel: newsDetailsViewModel)

                    self?.viewController?.navigationController?.pushViewController(newsDetailsViewController, animated: true)
                }
                .store(in: &subscriptions)
        }

        bind()
    }
}
