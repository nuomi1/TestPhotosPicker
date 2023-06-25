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
    case video(AVURLAsset)
    case failed(Error)

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .image, .livePhoto, .video, .failed:
            return false
        }
    }

    var image: UIImage? {
        switch self {
        case let .image(image):
            return image
        case .loading, .livePhoto, .video, .failed:
            return nil
        }
    }

    var livePhoto: PHLivePhoto? {
        switch self {
        case let .livePhoto(livePhoto):
            return livePhoto
        case .loading, .image, .video, .failed:
            return nil
        }
    }

    var video: AVURLAsset? {
        switch self {
        case let .video(video):
            return video
        case .loading, .image, .livePhoto, .failed:
            return nil
        }
    }

    var isFailed: Bool {
        switch self {
        case .failed:
            return true
        case .loading, .image, .livePhoto, .video:
            return false
        }
    }
}

enum ImageLoadingError: Error {
    case contentTypeNotSupported
}

extension NSItemProvider {

    func loadTransferable<T: Transferable & NSItemProviderReading>(type: T.Type) async throws -> T? {
        guard _canLoadObject(ofClass: type) else { return nil }
        let received = try await withCheckedThrowingContinuation { continuation in
            _ = loadTransferable(type: type) { result in
                continuation.resume(with: result)
            }
        }
        return received
    }

    private func _canLoadObject(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        if aClass is PHLivePhoto.Type { return canLoadObject(ofClass: aClass) }
        if aClass is AVURLAsset.Type { return hasItemConformingToTypeIdentifier(UTType.movie.identifier) }
        if aClass is UIImage.Type { return canLoadObject(ofClass: aClass) }
        assertionFailure()
        return false
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
