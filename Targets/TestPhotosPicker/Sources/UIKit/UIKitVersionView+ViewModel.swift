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

    class ImageAttachment: ImageViewModel<PHPickerResult>, Hashable {

        override var loadTransferableProviding: LoadTransferableProviding { item.itemProvider }

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
