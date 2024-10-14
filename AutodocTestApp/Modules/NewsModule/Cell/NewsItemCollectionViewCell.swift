//
//  NewsItemCollectionViewCell.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 12.10.2024.
//

import UIKit

extension NewsViewController {
    final class NewsItemCollectionViewCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)

            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 20
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor(red: 0.906, green: 0.926, blue: 0.946, alpha: 1).cgColor

            func addSubviews() {
                contentView.addSubview(stackView)
                [titleImageView, titleLabel].forEach(stackView.addArrangedSubview)
            }

            func setConstraints() {
                NSLayoutConstraint.activate([
                    stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

                    titleImageView.widthAnchor.constraint(equalToConstant: 116),
                    titleImageView.heightAnchor.constraint(equalToConstant: 116)
                ])
            }

            addSubviews()
            setConstraints()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            loadTitleImageTask?.cancel()
            titleLabel.text = ""
            titleImageView.image = UIImage(named: "placeholder")
        }

        override var isSelected: Bool {
            didSet {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.backgroundColor = self.isSelected ?
                        .init(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0) :
                        UIColor.white
                    self.transform = self.isSelected ?
                        CGAffineTransform(scaleX: 0.9, y: 0.9) :
                        CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
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
            $0.image = UIImage(named: "placeholder")
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        private var loadTitleImageTask: Task<Void, Never>?

        func bind(to newsItem: NewsEntity.NewsItem) {
            titleLabel.text = newsItem.title

            loadTitleImageTask = Task { [weak self] in
                do {
                    guard let titleImageUrl = newsItem.titleImageUrl else {
                        throw URLError(.cannotDecodeContentData)
                    }

                    try await self?.titleImageView.setImage(by: titleImageUrl)
                } catch {
                    self?.titleImageView.image = UIImage(named: "placeholder")
                }
            }
        }
    }
}
