//
//  Constants.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-24.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

enum Constants {

    enum Tab {
        static let swiftUI = TabContentViewConfiguration(tabTitle: "SwiftUI", tabIcon: "sun.max", navigationTitle: "SwiftUI PhotosPicker")
        static let uiKit = TabContentViewConfiguration(tabTitle: "UIKit", tabIcon: "moon", navigationTitle: "UIKit PHPickerViewController")
    }

    enum List {
        static let emptyImage = "text.below.photo"
        static let emptyImageFont: Font.TextStyle = .largeTitle
        static let emptyImageUIFont: UIFont.TextStyle = .largeTitle
        static let emptyImageUIColor: UIColor = .black
        static let sectionIdentifier = "ImageList"
        static let spacing: CGFloat = 8
    }

    enum Cell {
        private static let maxOutsets = EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20)
        private static let minRowInsets = EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
        static let insets = maxOutsets + minRowInsets
        static let height: CGFloat = 44 * 2
        static let spacing: CGFloat = 8
        static let imageDescription = "Image Description"
        static let failedImage = "exclamationmark.triangle.fill"
        static let failedImageFont: Font.TextStyle = .largeTitle
        static let failedImageUIFont: UIFont.TextStyle = .largeTitle
        static let failedImageUIColor: UIColor = .black
    }

    enum PhotosPicker {
        static let title = "Select Photos"
        static let height: CGFloat = 44 * 3.5
    }
}
