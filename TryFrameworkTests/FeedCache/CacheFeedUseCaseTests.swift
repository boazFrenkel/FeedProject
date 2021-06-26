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
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedImage], with completion: @escaping SaveCompletion) {
        self.store.inserItems(items: items, timestemp: self.currentDate()) {[weak self] error in
            if self == nil { return }
            completion(error)
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func inserItems(items: [FeedImage], timestemp: Date, completion: @escaping InsertionCompletion)
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
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfuly()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfuly()
            store.completeInsertionSuccessfuly()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTHadBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { Date() })
         
        var recievedResults = [Error?]()
        sut?.save(items: [uniqueItem()]) { error in
            recievedResults.append(error)
        }

        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTHadBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { Date() })
         
        var recievedResults = [Error?]()
        sut?.save(items: [uniqueItem()]) { error in
            recievedResults.append(error)
        }

        store.completeDeletionSuccessfuly()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)

        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        let exp = expectation(description: "wait for save completion")
        var recievedError: Error?
        
        sut.save(items: [uniqueItem()]) { error in
            recievedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        

        XCTAssertEqual(recievedError as NSError?, expectedError, file: file, line: line)
    }
    
    private class FeedStoreSpy: FeedStore {
        
        enum RecievedMessage: Equatable {
            case deleteCachedFeed
            case insertItems( [FeedImage], Date)
        }
        
        private(set) var recievedMessages = [RecievedMessage]()
        private var deletionCompletions: [FeedStore.DeletionCompletion] = []
        private var insertionCompletions: [FeedStore.InsertionCompletion] = []
        
        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            self.deletionCompletions.append(completion)
            recievedMessages.append(RecievedMessage.deleteCachedFeed)
        }
        
        func inserItems(items: [FeedImage], timestemp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            insertionCompletions.append(completion)
            recievedMessages.append(.insertItems(items, timestemp))
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfuly(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func completeInsertionSuccessfuly(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "some description", location: "some location", imageURL: anyURL())
    }
    
}
