//
//  SwiftUIVersionView+ViewModel.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-19.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import PhotosUI
import SwiftUI

extension SwiftUIVersionView {

    typealias ViewModel = ListViewModel<ImageAttachment>
}

extension SwiftUIVersionView {

    @MainActor
    class ImageAttachment: ObservableObject, Identifiable, ItemViewModelInitializable {

        enum Status {
            case loading
            case finished(Image)
            case failed(Error)

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

        private let pickerItem: PhotosPickerItem

        @Published
        var imageStatus: Status?

        @Published
        var imageDescription = ""

        nonisolated var id: String { pickerItem.id }

        required nonisolated init(_ item: PhotosPickerItem) {
            pickerItem = item
        }

        func loadImage() async {
            guard imageStatus == nil || imageStatus?.isFailed == true else { return }

            imageStatus = .loading

            do {
//                if let image = try await pickerItem.loadTransferable(type: Image.self) {
//                    imageStatus = .finished(image)
//                } else {
//                    throw LoadingError.contentTypeNotSupported
//                }
                if let data = try await pickerItem.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    imageStatus = .finished(Image(uiImage: uiImage))
                } else {
                    throw LoadingError.contentTypeNotSupported
                }
            } catch {
                imageStatus = .failed(error)
            }
        }
    }
}

// MARK: - DON'T DO THIS IN PRODUCTION

extension PhotosPickerItem: Identifiable {

    public var id: String { itemIdentifier! }
}
