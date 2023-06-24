//
//  TabContentView.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-24.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation
import SwiftUI

struct TabContentView<Content: View>: View {

    typealias Configuration = TabContentViewConfiguration

    private let configuration: Configuration
    private let content: Content

    init(configuration: Configuration, @ViewBuilder content: () -> Content) {
        self.configuration = configuration
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(configuration.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem {
            Label(
                title: { Text(configuration.tabTitle) },
                icon: { Image(systemName: configuration.tabIcon) }
            )
        }
    }
}

struct TabContentViewConfiguration: Hashable {
    var tabTitle: String
    var tabIcon: String
    var navigationTitle: String
}
