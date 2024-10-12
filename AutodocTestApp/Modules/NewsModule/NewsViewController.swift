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

    private let tableView = UITableView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsSelection = true
        $0.separatorStyle = .none
        $0.backgroundColor = nil
        $0.bouncesZoom = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceHorizontal = false
        $0.register(
            NewsItemTableViewCell.self,
            forCellReuseIdentifier: String(describing: NewsItemTableViewCell.self)
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
            [tableView, loadingTitle].forEach(view.addSubview)
        }

        func setConstraints() {
            NSLayoutConstraint.activate([
                loadingTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        tableView.delegate = self

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
            tableView.isHidden = true
        case .success(let newsItems):
            self.newsItems.append(contentsOf: newsItems)

            loadingTitle.isHidden = true
            tableView.isHidden = false

            var snapshot = NSDiffableDataSourceSnapshot<Section, NewsModel.NewsItem>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(self.newsItems, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: true)
        case .noResults:
            loadingTitle.isHidden = false
            tableView.isHidden = true
        case .failure:
            loadingTitle.isHidden = false
            tableView.isHidden = true
        }
    }

    private func makeDataSource() -> UITableViewDiffableDataSource<Section, NewsModel.NewsItem> {
        .init(tableView: tableView) { [unowned self] tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: NewsItemTableViewCell.self),
                for: indexPath
            ) as? NewsItemTableViewCell
            else {
                fatalError("Invalid cell")
            }

            if (indexPath.row + 1) == self.newsItems.count {
                currentPage.send(currentPage.value + 1)
            }

            cell.bind(to: itemIdentifier)

            return cell
        }
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 190 }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let snapshot = dataSource.snapshot()
        selection.send(snapshot.itemIdentifiers[indexPath.row])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
