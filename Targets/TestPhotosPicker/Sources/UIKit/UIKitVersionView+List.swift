//
//  UIKitVersionView+List.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-20.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import UIKit

extension UIKitVersionView.UIKitVersionViewController {

    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(88))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
        return .list(using: .init(appearance: .insetGrouped))
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<String, ViewModel.ImageAttachment> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ViewModel.ImageAttachment> { cell, _, itemIdentifier in
            var contentConfiguration = ImageCell.ContentConfiguration()
            contentConfiguration.imageAttachment = itemIdentifier
            cell.contentConfiguration = contentConfiguration
        }
        let dataSource = UICollectionViewDiffableDataSource<String, ViewModel.ImageAttachment>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        }
        return dataSource
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, ViewModel.ImageAttachment>()
        snapshot.appendSections([Constants.List.sectionIdentifier])
        snapshot.appendItems(viewModel.attachments, toSection: Constants.List.sectionIdentifier)
        dataSource.apply(snapshot)
        emptyView.isHidden = !viewModel.attachments.isEmpty
    }
}

extension UIKitVersionView.UIKitVersionViewController {

    class ImageCell: UIView, UIContentView {

        private let stackView = UIStackView()
        private let textField = UITextField()
        private let spacer = UIView()
        private let activityIndicatorView = UIActivityIndicatorView()
        private let imageView = UIImageView()

        var configuration: UIContentConfiguration {
            didSet { updateContentConfiguration(configuration as! ContentConfiguration) }
        }

        private var imageViewWidthConstraint: NSLayoutConstraint?

        init(configuration: ContentConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
            prepare()
            updateContentConfiguration(configuration)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func prepare() {
            // stackView

            stackView.alignment = .center
            stackView.spacing = Constants.Cell.spacing

            stackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Cell.insets.top),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Cell.insets.leading),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Cell.insets.trailing),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Cell.insets.bottom),
                stackView.heightAnchor.constraint(equalToConstant: Constants.Cell.height),
            ])

            // textField

            textField.placeholder = Constants.Cell.imageDescription

            stackView.addArrangedSubview(textField)

            // spacer

            stackView.addArrangedSubview(spacer)

            // activityIndicatorView

            stackView.addArrangedSubview(activityIndicatorView)

            // imageView

            var symbolConfiguration = UIImage.SymbolConfiguration.unspecified
            symbolConfiguration = symbolConfiguration.applying(UIImage.SymbolConfiguration(textStyle: Constants.Cell.failedImageUIFont))
            symbolConfiguration = symbolConfiguration.applying(UIImage.SymbolConfiguration(paletteColors: [Constants.Cell.failedImageUIColor]))
            imageView.preferredSymbolConfiguration = symbolConfiguration

            stackView.addArrangedSubview(imageView)
        }

        private func updateContentConfiguration(_ configuration: ContentConfiguration) {
            // imageAttachment

            assert(configuration.imageAttachment != nil)
            let isLoading = configuration.imageAttachment?.imageStatus?.isLoading == true
            let image = configuration.imageAttachment?.imageStatus?.image
            let isFailed = configuration.imageAttachment?.imageStatus?.isFailed == true
            let resolvedImage = isFailed ? UIImage(systemName: Constants.Cell.failedImage) : image

            // textField

            textField.text = configuration.imageAttachment?.imageDescription

            // activityIndicatorView

            activityIndicatorView.isHidden = !isLoading
            if isLoading {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }

            // imageView

            imageView.image = resolvedImage
            imageView.isHidden = resolvedImage == nil

            NSLayoutConstraint.deactivate([imageViewWidthConstraint].compactMap { $0 })
            if let size = resolvedImage?.size, size.height != 0, resolvedImage?.isSymbolImage == false {
                imageViewWidthConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: size.width / size.height)
                NSLayoutConstraint.activate([imageViewWidthConstraint].compactMap { $0 })
            }

            // imageStatus

            if configuration.imageAttachment?.imageStatus == nil {
                Task { [weak self] in
                    guard let self = self else { return }
                    await configuration.imageAttachment?.loadImage()
                    self.configuration = self.configuration
                }
            }
        }
    }
}

extension UIKitVersionView.UIKitVersionViewController.ImageCell {

    struct ContentConfiguration: UIContentConfiguration {

        var imageAttachment: UIKitVersionView.UIKitVersionViewController.ViewModel.ImageAttachment?

        func makeContentView() -> UIView & UIContentView {
            let contentView = UIKitVersionView.UIKitVersionViewController.ImageCell(configuration: self)
            return contentView
        }

        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            return self
        }
    }
}
