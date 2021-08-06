//
//  LocalFeedLoader.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 06/08/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveCompletion = (Error?) -> Void
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping SaveCompletion) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping SaveCompletion) {
        self.store.inserItems(items: items.toLocale(), timestemp: self.currentDate()) {[weak self] error in
            if self == nil { return }
            completion(error)
        }
    }
}
