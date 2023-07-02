//
//  ListViewModel.swift
//  TestPhotosPicker
//
//  Created by nuomi1 on 2023-06-24.
//  Copyright © 2023 nuomi1. All rights reserved.
//

import Foundation

protocol ItemViewModelInitializable<Item> {

    associatedtype Item

    init(_ item: Item)
}

@MainActor
final class ListViewModel<ItemViewModel: Identifiable & ItemViewModelInitializable>: ObservableObject
    where ItemViewModel.Item: Identifiable, ItemViewModel.ID == ItemViewModel.Item.ID {

    @Published
    var items: [ItemViewModel.Item] = [] {
        didSet { updateItemViewModelsIfNeeded() }
    }

    @Published
    var itemViewModels: [ItemViewModel] = []

    private var cache: [ItemViewModel.Item.ID: ItemViewModel] = [:]

    private func updateItemViewModelsIfNeeded() {
        let newItemViewModels = items.map { cache[$0.id] ?? ItemViewModel($0) }
        let newCache = newItemViewModels.reduce(into: [:]) { $0[$1.id] = $1 }
        itemViewModels = newItemViewModels
        cache = newCache
    }
}
