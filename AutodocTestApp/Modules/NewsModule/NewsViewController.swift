//
//  NewsViewController.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 10.10.2024.
//

import UIKit
import Combine

final class NewsViewController: UIViewController {
    final class NewsItemTableViewCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            backgroundColor = nil
            selectedBackgroundView = .init().then {
                $0.backgroundColor = .init(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0)
            }

            func addSubviews() {
                contentView.addSubview(rootView)
                rootView.addSubview(stackView)
                [titleImageView, titleLabel].forEach(stackView.addArrangedSubview)
            }

            func setConstraints() {
                NSLayoutConstraint.activate([
                    rootView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    rootView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    rootView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                    rootView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),


                    stackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
                    stackView.topAnchor.constraint(equalTo: rootView.topAnchor),
                    stackView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
                    stackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),

                    titleImageView.widthAnchor.constraint(equalToConstant: 100),
                    titleImageView.heightAnchor.constraint(equalToConstant: 100)
                ])
            }

            addSubviews()
            setConstraints()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            rootView.backgroundColor = selected ? .init(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0) : UIColor.white
        }

        override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            rootView.backgroundColor = isSelected || highlighted ? .init(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0) : UIColor.white
        }

        private let rootView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor(red: 0.906, green: 0.926, blue: 0.946, alpha: 1).cgColor
        }

        private let stackView = UIStackView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
            $0.isLayoutMarginsRelativeArrangement = true
            $0.axis = .horizontal
            $0.alignment = .top
            $0.spacing = 16
        }

        private let titleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .black
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
            $0.numberOfLines = 4
        }

        private let titleImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        func bind(to newsItem: NewsModel.NewsItem) {
            titleLabel.text = newsItem.title

            let placeholderImage = UIImage(named: "placeholder")
            if let titleImageUrl = newsItem.titleImageUrl, let imageUrl = URL(string: titleImageUrl) {
                titleImageView.setImage(url: imageUrl, placeholder: placeholderImage)
            } else {
                titleImageView.image = placeholderImage
            }
        }
    }

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

    private let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsSelection = true
        $0.separatorStyle = .none
        $0.backgroundColor = nil
        $0.bouncesZoom = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceHorizontal = false
        $0.register(
            NewsItemTableViewCell.self,
            forCellReuseIdentifier: String(describing: NewsItemTableViewCell.self)
        )
        $0.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        if #available(iOS 15.0, *) {
           $0.sectionHeaderTopPadding = .zero
        }
        $0.keyboardDismissMode = .onDrag
        var rect = CGRect.zero
        rect.size.height = .leastNormalMagnitude
        $0.tableHeaderView = UIView(frame: rect)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "News"

        guard let view = view else { return }

        view.backgroundColor = .init(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0)

        func addSubviews() {
            [loadingTitle, tableView].forEach(view.addSubview)
        }

        func setConstraints() {
            NSLayoutConstraint.activate([
                loadingTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
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
