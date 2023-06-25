//
//  ImageViewModel.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-25.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import AVKit
import Foundation

@MainActor
class ImageViewModel<Item: Identifiable>: ObservableObject, Identifiable, ItemViewModelInitializable {

    let item: Item

    @Published
    var imageStatus: ImageStatus?

    @Published
    var imageDescription = ""

    @Published
    var videoPlayer: AVPlayer?

    @Published
    var videoAspectRatio: CGFloat?

    @Published
    var isPlaying: Bool = false

    nonisolated var id: Item.ID { item.id }

    required nonisolated init(_ item: Item) {
        self.item = item
    }

    func loadImage() async {
        fatalError("override")
    }

    @discardableResult
    final func calculateVideoSize() async -> CGSize? {
        guard videoAspectRatio == nil, let video = imageStatus?.video else { return nil }
        guard let videoSize = try? await video.videoSize else { return nil }
        let aspectRatio = videoSize.width / videoSize.height
        videoAspectRatio = aspectRatio
        return videoSize
    }

    final func playOrStopVideo() {
        if isPlaying {
            videoPlayer?.pause()
        } else {
            videoPlayer?.play()
        }
        isPlaying.toggle()
        videoPlayer?.seek(to: .zero)
    }
}

extension AVAsset {

    fileprivate var videoSize: CGSize {
        get async throws {
            let tracks = try await loadTracks(withMediaType: .video)
            assert(tracks.count == 1)
            guard let track = tracks.first else { throw ImageLoadingError.contentTypeNotSupported }
            let (naturalSize, preferredTransform) = try await track.load(.naturalSize, .preferredTransform)
            return naturalSize.applying(preferredTransform)
        }
    }
}
