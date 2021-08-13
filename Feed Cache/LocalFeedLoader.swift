//
//  LocalFeedLoader.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 06/08/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    
    public typealias SaveResult = (Error?) -> Void
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping SaveResult) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    public func load(_ completion: @escaping (FeedLoader.Result) -> Void) {
        
        store.retrieve { result in
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let feed):
                completion(.success(feed.toFeedImage()))
            }
        }
    }
    
    private func cache(_ items: [FeedImage], with completion: @escaping SaveResult) {
        self.store.insertFeed(items.toLocale(), timestemp: self.currentDate()) {[weak self] error in
            if self == nil { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocale() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)}
    }
    
}

private extension Array where Element == LocalFeedImage {
    func toFeedImage() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
