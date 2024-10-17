//
//  NewsRouter.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import class UIKit.UIViewController

protocol NewsRouterProtocol: AnyObject {
    func showNewsDetails(with newsItem: NewsEntity.NewsItem)
}

final class NewsRouter {
    weak var viewController: UIViewController?
}

extension NewsRouter: NewsRouterProtocol {
    func showNewsDetails(with newsItem: NewsEntity.NewsItem) {
        let newsDetailsViewModel = NewsDetailsViewModel(newsItem: newsItem)
        let newsDetailsViewController = NewsDetailsViewController(viewModel: newsDetailsViewModel)

        viewController?.navigationController?.pushViewController(newsDetailsViewController, animated: true)
    }
}
