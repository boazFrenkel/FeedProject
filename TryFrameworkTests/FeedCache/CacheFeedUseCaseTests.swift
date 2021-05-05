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
    typealias SaveCompletion = (Error?) -> Void
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedImage], completion: @escaping SaveCompletion) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.store.inserItems(items: items, timestemp: self.currentDate())
            } else {
                completion(error)
            }
            
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    enum RecievedMessage: Equatable {
        case deleteCachedFeed
        case insertItems( [FeedImage], Date)
    }
    
    private(set) var recievedMessages = [RecievedMessage]()
    private var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        self.deletionCompletions.append(completion)
        recievedMessages.append(.deleteCachedFeed)
    }
    
    func inserItems(items: [FeedImage], timestemp: Date) {
        recievedMessages.append(.insertItems(items, timestemp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfuly(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save(items: [uniqueItem(), uniqueItem()]) { _ in }
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_DoesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        sut.save(items: [uniqueItem(), uniqueItem()]) { _ in }
        let deletionError = anyNSError()
        
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestempOnSuccessfulDeletion() {
        let timestemp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestemp })
        sut.save(items: items) { _ in }
        store.completeDeletionSuccessfuly()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insertItems(items, timestemp)])
    }
    
    func test_save_failsOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        let exp = expectation(description: "wait for save completion")
        var recievedError: Error?
        sut.save(items: items) { error in
            recievedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 0.1)
        

        XCTAssertEqual(recievedError as NSError?, deletionError)
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
