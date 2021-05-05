//
//  CacheFeedUseCaseTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 15/04/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import XCTest
import TryFramework

class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedImage]) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.store.inserItems(items: items, timestemp: self.currentDate())
            }
            
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedFeedCallCount = 0
    var insertionCallCount = 0
    var insertions = [(items: [FeedImage], timestemp: Date)]()
    private var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        self.deletionCompletions.append(completion)
    }
    
    func inserItems(items: [FeedImage], timestemp: Date) {
        insertionCallCount += 1
        insertions.append((items, timestemp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
    }
    
    func completeDeletionSuccessfuly(at index: Int = 0) {
        insertionCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save(items: [uniqueItem(), uniqueItem()])
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_DoesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        sut.save(items: [uniqueItem(), uniqueItem()])
        let deletionError = anyNSError()
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertionCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        sut.save(items: [uniqueItem(), uniqueItem()])
        store.completeDeletionSuccessfuly()
        
        XCTAssertEqual(store.insertionCallCount, 1)
    }
    
    func test_save_requestsNewCacheInsertionWithTimestempOnSuccessfulDeletion() {
        let timestemp = Date()
        let (sut, store) = makeSUT(currentDate: { timestemp })
        sut.save(items: [uniqueItem(), uniqueItem()])
        store.completeDeletionSuccessfuly()
        
        XCTAssertEqual(store.insertionCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)

        return (sut, store)
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "some description", location: "some location", imageURL: anyURL())
    }
    
}
