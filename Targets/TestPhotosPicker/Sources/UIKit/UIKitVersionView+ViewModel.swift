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
                if let livePhoto = try await pickerResult.itemProvider.loadTransferable(type: PHLivePhoto.self) {
                    imageStatus = .livePhoto(livePhoto)
                } else if let image = try await pickerResult.itemProvider.loadTransferable(type: UIImage.self) {
                    imageStatus = .image(image)
                } else {
                    throw ImageLoadingError.contentTypeNotSupported
                }
            } catch {
                imageStatus = .failed(error)
            }
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
