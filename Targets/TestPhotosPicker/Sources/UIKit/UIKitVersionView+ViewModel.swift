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

    @MainActor
    class ViewModel: ObservableObject {

        @Published
        var selection: [PHPickerResult] = [] {
            didSet { updateImagesIfNeeded() }
        }

        @Published
        var attachments: [ImageAttachment] = []

        private var attachmentByIdentifier: [String: ImageAttachment] = [:]

        private func updateImagesIfNeeded() {
            let newAttachments = selection.map { attachmentByIdentifier[$0.id] ?? ImageAttachment($0) }
            let newAttachmentByIdentifier = newAttachments.reduce(into: [:]) { $0[$1.id] = $1 }
            attachments = newAttachments
            attachmentByIdentifier = newAttachmentByIdentifier
        }
    }
}

extension UIKitVersionView.UIKitVersionViewController.ViewModel {

    @MainActor
    class ImageAttachment: ObservableObject, Identifiable, Hashable {

        enum Status {
            case loading
            case finished(UIImage)
            case failed(Error)

            var isLoading: Bool {
                switch self {
                case .loading:
                    return true
                case .finished, .failed:
                    return false
                }
            }

            var image: UIImage? {
                switch self {
                case .loading, .failed:
                    return nil
                case let .finished(image):
                    return image
                }
            }

            var isFailed: Bool {
                switch self {
                case .loading, .finished:
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

        init(_ pickerResult: PHPickerResult) {
            self.pickerResult = pickerResult
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
                    imageStatus = Bool.random() ? .finished(uiImage) : .failed(LoadingError.contentTypeNotSupported)
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
