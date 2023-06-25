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

        private let pickerItem: PhotosPickerItem

        @Published
        var imageStatus: ImageStatus?

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
//                    imageStatus = .image(image)
//                } else {
//                    throw LoadingError.contentTypeNotSupported
//                }

                if let livePhoto = try await pickerItem.loadTransferable(type: PHLivePhoto.self) {
                    imageStatus = .livePhoto(livePhoto)
                } else if let image = try await pickerItem.loadTransferable(type: UIImage.self) {
                    imageStatus = .image(image)
                } else {
                    throw ImageLoadingError.contentTypeNotSupported
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
