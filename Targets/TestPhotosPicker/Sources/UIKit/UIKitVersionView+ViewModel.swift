//
//  UIKitVersionView+ViewModel.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-19.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import PhotosUI
import UIKit

extension UIKitVersionView.UIKitVersionViewController {

    typealias ViewModel = ListViewModel<ImageAttachment>
}

extension UIKitVersionView.UIKitVersionViewController {

    @MainActor
    class ImageAttachment: ObservableObject, Identifiable, Hashable, ItemViewModelInitializable {

        private let pickerResult: PHPickerResult

        @Published
        var imageStatus: ImageStatus?

        @Published
        var imageDescription = ""

        nonisolated var id: String { pickerResult.id }

        required nonisolated init(_ item: PHPickerResult) {
            pickerResult = item
        }

        func loadImage() async {
            guard imageStatus == nil || imageStatus?.isFailed == true else { return }

            imageStatus = .loading

            do {
                if let livePhoto = try await loadTransferableLivePhoto(pickerResult.itemProvider) {
                    imageStatus = .livePhoto(livePhoto)
                } else if let image = try await loadTransferableImage(pickerResult.itemProvider) {
                    imageStatus = .image(image)
                } else {
                    throw ImageLoadingError.contentTypeNotSupported
                }
            } catch {
                imageStatus = .failed(error)
            }
        }

        private func loadTransferableImage(_ itemProvider: NSItemProvider) async throws -> UIImage? {
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else { return nil }
            let data = try await withCheckedThrowingContinuation { continuation in
                _ = itemProvider.loadTransferable(type: Data.self) { result in
                    continuation.resume(with: result)
                }
            }
            let image = UIImage(data: data)
            return image
        }

        private func loadTransferableLivePhoto(_ itemProvider: NSItemProvider) async throws -> PHLivePhoto? {
            guard itemProvider.canLoadObject(ofClass: PHLivePhoto.self) else { return nil }
            let livePhoto = try await withCheckedThrowingContinuation { continuation in
                _ = itemProvider.loadTransferable(type: PHLivePhoto.self) { result in
                    continuation.resume(with: result)
                }
            }
            return livePhoto
        }

        nonisolated static func == (lhs: ImageAttachment, rhs: ImageAttachment) -> Bool {
            lhs.id == rhs.id
        }

        nonisolated func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

// MARK: - DON'T DO THIS IN PRODUCTION

extension PHPickerResult: Identifiable {

    public var id: String { assetIdentifier! }
}
