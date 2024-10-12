//
//  NewsItemTableViewCell.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 12.10.2024.
//

import UIKit

extension NewsViewController {
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

        override func prepareForReuse() {
            super.prepareForReuse()

            titleImageLoadingTask?.cancel()
            titleLabel.text = ""
            titleImageView.image = UIImage(named: "placeholder")
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
            $0.image = UIImage(named: "placeholder")
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        private let imageCache = NSCache<NSString, UIImage>()
        private var titleImageLoadingTask: Task<Void, Error>?

        func bind(to newsItem: NewsModel.NewsItem) {
            func setTitleImageUrl() {
                if let titleImageUrl = newsItem.titleImageUrl, let imageUrl = URL(string: titleImageUrl) {
                    if let imageFromCache = imageCache.object(forKey: imageUrl.absoluteString as NSString) {
                        titleImageView.image = imageFromCache
                    } else {
                        titleImageLoadingTask = titleImageView.makeImageLoadingTask(imageUrl, with: imageCache)
                    }
                } else {
                    titleImageView.image = UIImage(named: "placeholder")
                }
            }

            titleLabel.text = newsItem.title
            setTitleImageUrl()
        }
    }
}
