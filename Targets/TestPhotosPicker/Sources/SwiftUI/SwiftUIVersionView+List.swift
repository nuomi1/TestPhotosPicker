//
//  SwiftUIVersionView+List.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-19.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import AVKit
import Foundation
import PhotosUI
import SwiftUI

extension SwiftUIVersionView {

    struct ImageList: View {

        @ObservedObject
        var viewModel: ViewModel

        var body: some View {
            if viewModel.itemViewModels.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: Constants.List.emptyImage)
                        .font(.system(Constants.List.emptyImageFont))
                    Spacer()
                }
            } else {
                List(viewModel.itemViewModels) { imageAttachment in
                    ImageAttachmentView(imageAttachment: imageAttachment)
                }
            }
        }
    }
}

extension SwiftUIVersionView {

    struct ImageAttachmentView: View {

        @ObservedObject
        var imageAttachment: ImageAttachment

        var body: some View {
            HStack {
                TextField(Constants.Cell.imageDescription, text: $imageAttachment.imageDescription)
                Spacer()
                switch imageAttachment.imageStatus {
                case .loading:
                    ProgressView()
                case let .image(image):
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case let .livePhoto(livePhoto):
                    LivePhotoView(livePhoto: livePhoto)
                        .aspectRatio(livePhoto.size.width / livePhoto.size.height, contentMode: .fit)
                case .video:
                    VideoPlayer(player: imageAttachment.videoPlayer!) {
                        Button {
                            imageAttachment.playOrStopVideo()
                        } label: {
                            Image(systemName: imageAttachment.isPlaying ? Constants.Cell.stopImage : Constants.Cell.playImage)
                        }
                    }
                    .aspectRatio(imageAttachment.videoAspectRatio, contentMode: .fit)
                    .task {
                        await imageAttachment.calculateVideoSize()
                    }
                case .failed:
                    Image(systemName: Constants.Cell.failedImage)
                        .font(.system(Constants.Cell.failedImageFont))
                case nil:
                    EmptyView()
                }
            }
            .frame(height: Constants.Cell.height)
            .task {
                if imageAttachment.imageStatus == nil {
                    await imageAttachment.loadImage()
                }
            }
        }
    }
}

struct LivePhotoView: UIViewRepresentable {

    typealias UIViewType = PHLivePhotoView

    let livePhoto: PHLivePhoto

    private let livePhotoView = PHLivePhotoView()

    func makeUIView(context: Context) -> UIViewType {
        livePhotoView.livePhoto = livePhoto
        return livePhotoView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // no-op
    }
}
