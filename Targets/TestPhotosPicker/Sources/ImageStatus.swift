//
//  ImageStatus.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-25.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import CoreTransferable
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

extension NSItemProvider {

    func loadTransferable<T: Transferable & NSItemProviderReading>(type: T.Type) async throws -> T? {
        guard canLoadObject(ofClass: type) else { return nil }
        let received = try await withCheckedThrowingContinuation { continuation in
            _ = loadTransferable(type: type) { result in
                continuation.resume(with: result)
            }
        }
        return received
    }
}

// MARK: - DON'T DO THIS IN PRODUCTION

extension UIImage: Transferable {

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else { throw ImageLoadingError.contentTypeNotSupported }
            return image
        }
    }
}

extension AVURLAsset: Transferable {

    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { receivedFile in
            let fileManager = FileManager.default
            let fileName = receivedFile.file.lastPathComponent
            let copingFile = fileManager.temporaryDirectory.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: copingFile.path()) {
                try fileManager.removeItem(at: copingFile)
            }
            try fileManager.copyItem(at: receivedFile.file, to: copingFile)
            let asset = AVURLAsset(url: copingFile)
            return asset
        }
    }
}
