//
//  NewsDetailsViewController.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import UIKit
import Combine

final class NewsDetailsViewController: UIViewController {
    typealias ViewModel = NewsDetailsViewModelProtocol

    private var subscriptions = Set<AnyCancellable>()

    private let viewModel: ViewModel
    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let stackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 16
    }

    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.numberOfLines = 0
    }

    private let categoryTypeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.numberOfLines = 0
    }

    private let publishedDateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.numberOfLines = 0
    }

    private let titleImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }

    private let descriptionLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.numberOfLines = 0
    }

    private let imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "News Details"

        guard let view = view else { return }

        view.backgroundColor = .white

        func addSubviews() {
            view.addSubview(stackView)
            [titleLabel, categoryTypeLabel, publishedDateLabel, titleImageView, descriptionLabel].forEach(stackView.addArrangedSubview)
        }

        func setContraints() {
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.topAnchor.constraint(equalTo: view.topAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                titleImageView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }

        func bind() {
            let output = viewModel.transform(.init())

            output.state.sink(receiveValue: render).store(in: &subscriptions)
        }

        addSubviews()
        setContraints()
        bind()
    }

    private func render(_ newsState: NewsDetailsViewModel.NewsState) {
        switch newsState {
        case .render(let newsItem):
            titleLabel.text = newsItem.title
            categoryTypeLabel.text = newsItem.categoryType

            if let publishedDate = newsItem.publishedDate {
                publishedDateLabel.text = DateFormatter().then { $0.dateFormat = "dd.MM.yyyy" }.string(from: publishedDate)
            }

            if let titleImageUrl = newsItem.titleImageUrl, let imageUrl = URL(string: titleImageUrl) {
                if let imageFromCache = imageCache.object(forKey: imageUrl.absoluteString as NSString) {
                    titleImageView.image = imageFromCache
                } else {
                    titleImageView.setImage(imageUrl, with: imageCache)
                }
            } else {
                titleImageView.isHidden = true
            }

            descriptionLabel.text = newsItem.description
        }
    }
}
