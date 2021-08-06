//
//  CacheFeedUseCaseTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 15/04/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import XCTest
import TryFramework



class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        sut.save(feed.models) { _ in }
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_DoesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        sut.save(feed.models) { _ in }
        let deletionError = anyNSError()
        
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestempOnSuccessfulDeletion() {
        let timestemp = Date()
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT(currentDate: { timestemp })
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfuly()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insertFeed(feed.local, timestemp)])
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
        let feed = uniqueImageFeed()
        var recievedResults = [Error?]()
        sut?.save(feed.models) { error in
            recievedResults.append(error)
        }

        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTHadBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { Date() })
        let feed = uniqueImageFeed()
        
        var recievedResults = [Error?]()
        sut?.save(feed.models) { error in
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

        let feed = uniqueImageFeed()
        let exp = expectation(description: "wait for save completion")
        var recievedError: Error?
        
        sut.save(feed.models) { error in
            recievedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        

        XCTAssertEqual(recievedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "some description", location: "some location", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)}
        return (models, local)
    }
    
}


