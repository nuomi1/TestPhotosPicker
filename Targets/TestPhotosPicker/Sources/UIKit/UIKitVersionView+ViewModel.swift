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

        enum Status {
            case loading
            case image(UIImage)
            case failed(Error)

            var isLoading: Bool {
                switch self {
                case .loading:
                    return true
                case .image, .failed:
                    return false
                }
            }

            var image: UIImage? {
                switch self {
                case .loading, .failed:
                    return nil
                case let .image(image):
                    return image
                }
            }

            var isFailed: Bool {
                switch self {
                case .loading, .image:
                    return false
                case .failed:
                    return true
                }
            }
        }

        enum LoadingError: Error {
            case contentTypeNotSupported
        }

        private let pickerResult: PHPickerResult

        @Published
        var imageStatus: Status?

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
                let data = try await withCheckedThrowingContinuation { [unowned self] continuation in
                    _ = self.pickerResult.itemProvider.loadTransferable(type: Data.self) { result in
                        continuation.resume(with: result)
                    }
                }

                if let uiImage = UIImage(data: data) {
                    imageStatus = .image(uiImage)
                } else {
                    throw LoadingError.contentTypeNotSupported
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
