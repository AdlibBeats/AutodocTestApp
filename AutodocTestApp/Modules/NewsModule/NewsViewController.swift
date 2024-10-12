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
    private let selection = PassthroughSubject<NewsModel.NewsItem, Never>()
    private let currentPage = CurrentValueSubject<Int, Never>(1)
    private lazy var dataSource = makeDataSource()

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
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: spacing, leading: 16, bottom: spacing, trailing: 16)
            section.interGroupSpacing = spacing

            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }()
    ).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = nil
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.bouncesZoom = false
        $0.register(
            NewsItemCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: NewsItemCollectionViewCell.self)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationController = navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationBar.tintColor = .black
        }

        navigationItem.title = "Новости"
        navigationItem.largeTitleDisplayMode = .automatic

        guard let view = view else { return }

        view.backgroundColor = .init(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0)

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

        collectionView.delegate = self

        func bind() {
            let output = viewModel.transform(.init(selection: selection, currentPage: currentPage))
            output.state
                .receive(on: RunLoop.main)
                .sink(receiveValue: render)
                .store(in: &subscriptions)
        }

        addSubviews()
        setConstraints()
        bind()
    }

    private var newsItems: [NewsModel.NewsItem] = []

    private func render(_ state: NewsViewModel.NewsState) {
        switch state {
        case .loading:
            loadingTitle.isHidden = false
            collectionView.isHidden = true
        case .success(let newsItems):
            self.newsItems.append(contentsOf: newsItems)

            loadingTitle.isHidden = true
            collectionView.isHidden = false

            var snapshot = NSDiffableDataSourceSnapshot<Section, NewsModel.NewsItem>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(self.newsItems, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: true)
        case .noResults:
            loadingTitle.isHidden = false
            collectionView.isHidden = true
        case .failure:
            loadingTitle.isHidden = false
            collectionView.isHidden = true
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, NewsModel.NewsItem> {
        .init(collectionView: collectionView) { [unowned self] collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: NewsItemCollectionViewCell.self),
                for: indexPath
            ) as? NewsItemCollectionViewCell
            else {
                fatalError("Invalid cell")
            }

            if (indexPath.row + 1) == newsItems.count {
                currentPage.send(currentPage.value + 1)
            }

            cell.bind(to: itemIdentifier)

            return cell
        }
    }
}

extension NewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let snapshot = dataSource.snapshot()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selection.send(snapshot.itemIdentifiers[indexPath.row])
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
