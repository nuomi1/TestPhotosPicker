//
//  UIKitVersionView+List.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-20.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import AVKit
import Foundation
import PhotosUI
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

    func makeDataSource() -> UICollectionViewDiffableDataSource<String, ImageAttachment> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ImageAttachment> { cell, _, itemIdentifier in
            var contentConfiguration = ImageAttachmentView.ContentConfiguration()
            contentConfiguration.imageAttachment = itemIdentifier
            cell.contentConfiguration = contentConfiguration
        }
        let dataSource = UICollectionViewDiffableDataSource<String, ImageAttachment>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        }
        return dataSource
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, ImageAttachment>()
        snapshot.appendSections([Constants.List.sectionIdentifier])
        snapshot.appendItems(viewModel.itemViewModels, toSection: Constants.List.sectionIdentifier)
        dataSource.apply(snapshot)
        emptyView.isHidden = !viewModel.itemViewModels.isEmpty
    }
}

extension UIKitVersionView.UIKitVersionViewController {

    class ImageAttachmentView: UIView, UIContentView {

        private let stackView = UIStackView()
        private let textField = UITextField()
        private let spacer = UIView()
        private let activityIndicatorView = UIActivityIndicatorView()
        private let imageView = UIImageView()
        private let livePhotoView = PHLivePhotoView()
        private let playerView = AVPlayerView()
        private let playerButton = UIButton(configuration: .plain())

        var configuration: UIContentConfiguration {
            didSet { updateContentConfiguration(configuration as! ContentConfiguration) }
        }

        private var imageViewWidthConstraint: NSLayoutConstraint?
        private var livePhotoViewWidthConstraint: NSLayoutConstraint?
        private var playerViewWidthConstraint: NSLayoutConstraint?

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

            // livePhotoView

            stackView.addArrangedSubview(livePhotoView)
            NSLayoutConstraint.activate([livePhotoView.heightAnchor.constraint(equalTo: stackView.heightAnchor)])

            // playerView

            stackView.addArrangedSubview(playerView)
            NSLayoutConstraint.activate([playerView.heightAnchor.constraint(equalTo: stackView.heightAnchor)])

            // playerButton

            playerButton.configurationUpdateHandler = { button in
                button.configuration?.image = UIImage(systemName: button.isSelected ? Constants.Cell.stopImage : Constants.Cell.playImage)
                button.configuration?.baseBackgroundColor = .clear
            }
            playerButton.addTarget(self, action: #selector(playOrStop), for: .touchUpInside)

            playerButton.translatesAutoresizingMaskIntoConstraints = false
            playerView.addSubview(playerButton)
            NSLayoutConstraint.activate([
                playerButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
                playerButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            ])
        }

        private func updateContentConfiguration(_ configuration: ContentConfiguration) {
            // imageAttachment

            assert(configuration.imageAttachment != nil)
            let isLoading = configuration.imageAttachment?.imageStatus?.isLoading == true
            let image = configuration.imageAttachment?.imageStatus?.image
            let livePhoto = configuration.imageAttachment?.imageStatus?.livePhoto
            let video = configuration.imageAttachment?.imageStatus?.video
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

            updateWidthConstraint(imageView, resolvedImage?.size, &imageViewWidthConstraint, resolvedImage?.isSymbolImage == false)

            // livePhotoView

            livePhotoView.livePhoto = livePhoto
            livePhotoView.isHidden = livePhoto == nil

            updateWidthConstraint(livePhotoView, livePhoto?.size, &livePhotoViewWidthConstraint)

            // playerView

            playerView.player = configuration.imageAttachment?.videoPlayer
            playerView.isHidden = video == nil

            if video != nil {
                Task { [weak self] in
                    guard let self = self else { return }
                    let size = await configuration.imageAttachment?.calculateVideoSize()
                    self.updateWidthConstraint(self.playerView, size, &self.playerViewWidthConstraint)
                }
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

        private func updateWidthConstraint(
            _ view: UIView,
            _ size: CGSize?,
            _ constraint: inout NSLayoutConstraint?,
            _ condition: @autoclosure () -> Bool = true
        ) {
            NSLayoutConstraint.deactivate([constraint].compactMap { $0 })
            if let size, size.height > 0, condition() {
                constraint = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: size.width / size.height)
                NSLayoutConstraint.activate([constraint].compactMap { $0 })
            }
        }

        @objc
        private func playOrStop(_ sender: UIButton) {
            let configuration = configuration as! ContentConfiguration
            configuration.imageAttachment?.playOrStopVideo()
            sender.isSelected.toggle()
        }
    }
}

extension UIKitVersionView.UIKitVersionViewController.ImageAttachmentView {

    struct ContentConfiguration: UIContentConfiguration {

        var imageAttachment: UIKitVersionView.UIKitVersionViewController.ImageAttachment?

        func makeContentView() -> UIView & UIContentView {
            let contentView = UIKitVersionView.UIKitVersionViewController.ImageAttachmentView(configuration: self)
            return contentView
        }

        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            return self
        }
    }
}

@dynamicMemberLookup
class AVPlayerView: UIView {

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<AVPlayerLayer, T>) -> T {
        get { playerLayer[keyPath: keyPath] }
        set { playerLayer[keyPath: keyPath] = newValue }
    }
}
