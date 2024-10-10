//
//  NewsRouter.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import UIKit
import Combine

protocol NewsRouterProtocol: AnyObject {
    var showNewsDetails: PassthroughSubject<NewsModel.NewsItem, Never> { get }
}

final class NewsRouter: NewsRouterProtocol {
    private var subscriptions = Set<AnyCancellable>()

    let showNewsDetails = PassthroughSubject<NewsModel.NewsItem, Never>()

    weak var viewController: UIViewController?

    init() {
        func bind() {
            showNewsDetails
                .sink(receiveValue: { [weak self] value in
                    let newsDetailsViewModel = NewsDetailsViewModel(newsItem: value)
                    let newsDetailsViewController = NewsDetailsViewController(viewModel: newsDetailsViewModel)

                    self?.viewController?.navigationController?.pushViewController(newsDetailsViewController, animated: true)
                })
                .store(in: &subscriptions)
        }

        bind()
    }
}
