//
//  SwiftUIVersionView+List.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-19.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import SwiftUI

extension SwiftUIVersionView {

    struct ImageList: View {

        @ObservedObject
        var viewModel: ViewModel

        var body: some View {
            if viewModel.attachments.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: Constants.List.emptyImage)
                        .font(.system(Constants.List.emptyImageFont))
                    Spacer()
                }
            } else {
                List(viewModel.attachments) { imageAttachment in
                    ImageAttachmentView(imageAttachment: imageAttachment)
                }
            }
        }
    }
}

extension SwiftUIVersionView {

    struct ImageAttachmentView: View {

        @ObservedObject
        var imageAttachment: ViewModel.ImageAttachment

        var body: some View {
            HStack {
                TextField(Constants.Cell.imageDescription, text: $imageAttachment.imageDescription)
                Spacer()
                switch imageAttachment.imageStatus {
                case .loading:
                    ProgressView()
                case let .finished(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
