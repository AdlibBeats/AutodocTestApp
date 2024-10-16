//
//  NewsViewController.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import UIKit
import Combine

final class NewsViewController: UIViewController {
    enum Section: CaseIterable {
        case main
    }

    typealias ViewModel = NewsViewModelProtocol

    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: ViewModel

    private let cellRegistration = UICollectionView.CellRegistration<NewsItemCollectionViewCell, NewsEntity.NewsItem> { cell, _, itemIdentifier in
        cell.bind(to: itemIdentifier)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, NewsEntity.NewsItem> = {
        func setNewPage(by indexPath: IndexPath) {
            let snapshot = dataSource.snapshot()

            if (indexPath.item + 1) == snapshot.itemIdentifiers.count {
                viewModel.currentPage += 1
            }
        }

        return .init(collectionView: collectionView) { [cellRegistration] collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            ).then { _ in setNewPage(by: indexPath) }
        }
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let loadingTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Loading..."
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 17, weight: .regular)
    }

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: {
            let spacing: CGFloat = 20
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing

            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.interSectionSpacing = 20
            config.contentInsetsReference = .layoutMargins

            let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
            return layout
        }()
    ).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = nil
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.bouncesZoom = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Новости"

        if let navigationController = navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationBar.tintColor = .black
        }

        guard let view = view else { return }

        view.backgroundColor = .init(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0)
        collectionView.delegate = self

        func addSubviews() {
            [collectionView, loadingTitle].forEach(view.addSubview)
        }

        func setConstraints() {
            NSLayoutConstraint.activate([
                loadingTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        func bind() {
            viewModel.state
                .receive(on: RunLoop.main)
                .sink(receiveValue: render)
                .store(in: &subscriptions)
        }

        addSubviews()
        setConstraints()
        bind()
    }

    private func render(_ state: NewsViewModel.NewsState) {
        switch state {
        case .loading:
            loadingTitle.isHidden = false
            collectionView.isHidden = true
        case .success(let items):
            loadingTitle.isHidden = true
            collectionView.isHidden = false

            var snapshot = NSDiffableDataSourceSnapshot<Section, NewsEntity.NewsItem>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(items, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: true)
        case .failure:
            loadingTitle.text = "Something went wrong."
            loadingTitle.isHidden = false
            collectionView.isHidden = true
        }
    }
}

extension NewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let snapshot = dataSource.snapshot()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.selection = snapshot.itemIdentifiers[indexPath.item]
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
