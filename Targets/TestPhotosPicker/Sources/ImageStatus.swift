//
//  ImageStatus.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-25.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import PhotosUI
import UIKit

enum ImageStatus {
    case loading
    case image(UIImage)
    case livePhoto(PHLivePhoto)
    case failed(Error)

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .image, .livePhoto, .failed:
            return false
        }
    }

    var image: UIImage? {
        switch self {
        case let .image(image):
            return image
        case .loading, .livePhoto, .failed:
            return nil
        }
    }

    var livePhoto: PHLivePhoto? {
        switch self {
        case let .livePhoto(livePhoto):
            return livePhoto
        case .loading, .image, .failed:
            return nil
        }
    }

    var isFailed: Bool {
        switch self {
        case .failed:
            return true
        case .loading, .image, .livePhoto:
            return false
        }
    }
}

enum ImageLoadingError: Error {
    case contentTypeNotSupported
}
