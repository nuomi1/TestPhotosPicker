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

    class ImageAttachment: ImageViewModel<PhotosPickerItem> {

        override var loadTransferableProviding: LoadTransferableProviding { item }
    }
}

// MARK: - DON'T DO THIS IN PRODUCTION

extension PhotosPickerItem: Identifiable {

    public var id: String { itemIdentifier! }
}
