//
//  CacheFeedUseCaseTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 15/04/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import XCTest

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
}
class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
