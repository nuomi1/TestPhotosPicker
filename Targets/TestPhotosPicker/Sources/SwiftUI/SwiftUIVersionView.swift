//
//  SwiftUIVersionView.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-19.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import PhotosUI
import SwiftUI

struct SwiftUIVersionView: View {

    @StateObject
    var viewModel = ViewModel()

    var body: some View {
        VStack {
            ImageList(viewModel: viewModel)
            Spacer()
            PhotosPicker(
                selection: $viewModel.items,
                maxSelectionCount: nil,
                selectionBehavior: .default,
                matching: nil,
                preferredItemEncoding: .automatic,
                photoLibrary: .shared()
            ) {
                Text(Constants.PhotosPicker.title)
            }
            .photosPickerStyle(.presentation)
            .photosPickerAccessoryVisibility(.automatic, edges: .all)
            .photosPickerDisabledCapabilities([])
            .frame(height: Constants.PhotosPicker.height)
        }
    }
}
