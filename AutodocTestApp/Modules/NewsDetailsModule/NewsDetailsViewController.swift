//
//  NewsDetailsViewController.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import UIKit

final class NewsDetailsViewController: UIViewController {
    typealias ViewModel = NewsDetailsViewModelProtocol

    private let viewModel: ViewModel
    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .white
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.bouncesZoom = false
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

    private var loadTitleImageTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        guard let view = view else { return }

        view.backgroundColor = .white

        func addSubviews() {
            view.addSubview(scrollView)
            scrollView.addSubview(stackView)
            [titleLabel, categoryTypeLabel, publishedDateLabel, titleImageView, descriptionLabel].forEach(stackView.addArrangedSubview)
        }

        func setContraints() {
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).then { $0.priority = .required },
                stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).then { $0.priority = .defaultLow },

                titleImageView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }

        func bind() {
            titleLabel.text = viewModel.newsItem.title
            categoryTypeLabel.text = viewModel.newsItem.categoryType

            let titleImageUrl = viewModel.newsItem.titleImageUrl
            if let publishedDate = viewModel.newsItem.publishedDate {
                publishedDateLabel.text = DateFormatter().then { $0.dateFormat = "dd.MM.yyyy" }.string(from: publishedDate)
            }

            loadTitleImageTask = Task { [titleImageView] in
                do {
                    guard let titleImageUrl = titleImageUrl else {
                        throw URLError(.cannotDecodeContentData)
                    }

                    try await titleImageView.setImage(by: titleImageUrl)
                } catch {
                    titleImageView.isHidden = true
                }
            }

            descriptionLabel.text = viewModel.newsItem.description
        }

        addSubviews()
        setContraints()
        bind()
    }
}
