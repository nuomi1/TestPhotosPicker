//
//  Transferable.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-25.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import AVKit
import CoreTransferable
import Foundation
import PhotosUI
import SwiftUI

protocol LoadTransferableProviding {
    func loadTransferable<T: Transferable & NSItemProviderReading>(type: T.Type) async throws -> T?
}

extension PhotosPickerItem: LoadTransferableProviding {}

extension NSItemProvider: LoadTransferableProviding {

    func loadTransferable<T: Transferable & NSItemProviderReading>(type: T.Type) async throws -> T? {
        guard _canLoadObject(ofClass: type) else { return nil }
        let received = try await withCheckedThrowingContinuation { continuation in
            _ = loadTransferable(type: type) { continuation.resume(with: $0) }
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
            if fileManager.fileExists(atPath: copingFile.path()) { try fileManager.removeItem(at: copingFile) }
            try fileManager.copyItem(at: receivedFile.file, to: copingFile)
            let asset = AVURLAsset(url: copingFile)
            return asset
        }
    }
}
