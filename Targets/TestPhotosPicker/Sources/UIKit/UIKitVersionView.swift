//
//  UIKitVersionView.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-19.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import PhotosUI
import SwiftUI
import UIKit

struct UIKitVersionView: View {

    var body: some View {
        UIKitVersionViewControllerRepresentable()
    }
}

extension UIKitVersionView {

    struct UIKitVersionViewControllerRepresentable: UIViewControllerRepresentable {

        typealias UIViewControllerType = UIKitVersionViewController

        func makeUIViewController(context: Context) -> UIViewControllerType {
            let viewController = UIKitVersionViewController()
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            // no-op
        }
    }
}

extension UIKitVersionView {

    @MainActor
    class UIKitVersionViewController: UIViewController {

        @ObservedObject
        var viewModel = ViewModel()

        let emptyView = UIImageView()
        lazy var compositionalLayout = makeCompositionalLayout()
        lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        lazy var dataSource = makeDataSource()
        let button = UIButton(configuration: .filled())

        override func viewDidLoad() {
            super.viewDidLoad()

            // collectionView

            collectionView.dataSource = dataSource

            collectionView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(collectionView)
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

            // emptyView

            var symbolConfiguration = UIImage.SymbolConfiguration.unspecified
            symbolConfiguration = symbolConfiguration.applying(UIImage.SymbolConfiguration(textStyle: Constants.List.emptyImageUIFont))
            symbolConfiguration = symbolConfiguration.applying(UIImage.SymbolConfiguration(paletteColors: [Constants.List.emptyImageUIColor]))
            emptyView.image = UIImage(systemName: Constants.List.emptyImage)
            emptyView.preferredSymbolConfiguration = symbolConfiguration

            emptyView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(emptyView)
            NSLayoutConstraint.activate([
                emptyView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
                emptyView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            ])

            // buttonContainer

            let buttonContainer = UILayoutGuide()

            view.addLayoutGuide(buttonContainer)
            NSLayoutConstraint.activate([
                buttonContainer.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Constants.List.spacing),
                buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                buttonContainer.heightAnchor.constraint(equalToConstant: Constants.PhotosPicker.height),
            ])

            // button

            button.configuration?.title = Constants.PhotosPicker.title
            button.addTarget(self, action: #selector(presentPickerViewController), for: .touchUpInside)

            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            ])
        }

        @objc
        private func presentPickerViewController() {
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.preselectedAssetIdentifiers = viewModel.items.map(\.id)
            configuration.selectionLimit = 0
            configuration.selection = .default
            configuration.filter = nil
            configuration.preferredAssetRepresentationMode = .automatic
            configuration.mode = .default
            configuration.disabledCapabilities = []
            let viewController = PHPickerViewController(configuration: configuration)
            viewController.delegate = self
            present(viewController, animated: true)
        }
    }
}

extension UIKitVersionView.UIKitVersionViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        viewModel.items = results
        picker.dismiss(animated: true)
        applySnapshot()
    }
}
