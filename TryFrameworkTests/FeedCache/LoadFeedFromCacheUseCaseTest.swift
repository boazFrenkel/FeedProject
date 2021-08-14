//
//  LoadFeedFromCacheUseCaseTest.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 06/08/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import XCTest
import TryFramework

class LoadFeedFromCacheUseCaseTest: XCTestCase {
    
    func test_init() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
        
    }
    
    func test_load_requestsCacheRetrievel() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievelError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnLessThenSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldtimestamp = fixedCurrentDate.adding(days: 7).adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldtimestamp)
        }
    }
    
    // MARK: - Helpers
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "some description", location: "some location", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)}
        return (models, local)
    }
    
    private func makeSUT(fixedCurrentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: fixedCurrentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait fror load completion")
        
        sut.load { (recivedResult) in
            switch (recivedResult, expectedResult) {
            case let (.success(recivedImages), .success(expectedImages)):
                XCTAssertEqual(recivedImages, expectedImages)
            case let (.failure(recievedError), .failure(expectedFailure)):
                XCTAssertEqual(recievedError as NSError, expectedFailure as NSError)
            default:
                XCTFail("Expected \(expectedResult) got \(recivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day , value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
